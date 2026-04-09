import 'package:flutter/material.dart';

import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_surveillance_model.dart';
import '../../data/services/manager_surveillance_companion_launcher.dart';
import '../../data/services/manager_surveillance_store.dart';
import 'manager_dvr_detail_screen.dart';
import 'manager_dvr_form_screen.dart';

class ManagerSurveillanceScreen extends StatefulWidget {
  const ManagerSurveillanceScreen({super.key});

  @override
  State<ManagerSurveillanceScreen> createState() =>
      _ManagerSurveillanceScreenState();
}

class _ManagerSurveillanceScreenState extends State<ManagerSurveillanceScreen> {
  final ManagerSurveillanceStore _store = ManagerSurveillanceStore.instance;
  late final Future<void> _loadFuture;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFuture = _store.ensureLoaded();
  }

  Future<void> _openDvrForm([ManagerDvr? dvr]) async {
    final result = await Navigator.push<ManagerDvr>(
      context,
      MaterialPageRoute<ManagerDvr>(
        builder: (_) => ManagerDvrFormScreen(initialDvr: dvr),
      ),
    );

    if (result == null) {
      return;
    }

    try {
      if (dvr == null) {
        await _store.addDvr(result);
      } else {
        await _store.updateDvr(result);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          dvr == null
              ? 'DVR ajouté avec succès.'
              : 'DVR mis à jour avec succès.',
        ),
      ),
    );
  }

  Future<void> _deleteDvr(ManagerDvr dvr) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer ce DVR ?'),
            content: Text(
              'Le DVR "${dvr.name}" et ses caméras seront retirés de la supervision.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await _store.deleteDvr(dvr.id);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('DVR supprimé.')),
    );
  }

  Future<void> _refresh() async {
    try {
      await _store.refreshFromApi();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _openCompanionApp() async {
    await ManagerSurveillanceCompanionLauncher.open(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Caméras manager',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Rafraîchir',
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDvrForm,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter DVR'),
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return AnimatedBuilder(
            animation: Listenable.merge(
              [
                _store.dvrs,
                _store.isSyncing,
                _store.isUsingDemoData,
                _store.syncMessage,
              ],
            ),
            builder: (context, _) {
              final dvrs = _filterDvrs(_store.dvrs.value);
              final allDvrs = _store.dvrs.value;

              final onlineDvrCount =
                  allDvrs.where((dvr) => dvr.status == 'online').length;

              final cameraCount = allDvrs.fold<int>(
                0,
                (sum, dvr) => sum + dvr.totalCameras,
              );

              final onlineCameraCount = allDvrs.fold<int>(
                0,
                (sum, dvr) => sum + dvr.onlineCameras,
              );

              final recordingCount = allDvrs.fold<int>(
                0,
                (sum, dvr) => sum + dvr.recordingCameras,
              );

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  children: [
                    _HeroCard(
                      dvrCount: allDvrs.length,
                      onlineDvrCount: onlineDvrCount,
                      cameraCount: cameraCount,
                      onlineCameraCount: onlineCameraCount,
                      isSyncing: _store.isSyncing.value,
                      onOpenCompanionApp: _openCompanionApp,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim().toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: 'Rechercher un DVR, un site ou une IP',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'DVR actifs',
                            value: '$onlineDvrCount',
                            icon: Icons.router_outlined,
                            accent: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Flux live',
                            value: '$onlineCameraCount/$cameraCount',
                            icon: Icons.live_tv_outlined,
                            accent: const Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Enregistrements',
                            value: '$recordingCount',
                            icon: Icons.fiber_manual_record_rounded,
                            accent: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'DVR surveillés',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${dvrs.length} résultat(s)',
                          style: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (dvrs.isEmpty)
                      _EmptyState(onCreate: _openDvrForm)
                    else
                      ...dvrs.map(
                        (dvr) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _DvrCard(
                            dvr: dvr,
                            onView: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      ManagerDvrDetailScreen(dvrId: dvr.id),
                                ),
                              );
                            },
                            onEdit: () => _openDvrForm(dvr),
                            onDelete: () => _deleteDvr(dvr),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<ManagerDvr> _filterDvrs(List<ManagerDvr> dvrs) {
    if (_searchQuery.isEmpty) {
      return dvrs;
    }

    return dvrs.where((dvr) {
      final haystack = <String>[
        dvr.name,
        dvr.site,
        dvr.ipAddress,
        dvr.networkAddress,
        dvr.protocol,
        dvr.status,
        dvr.streamProfile,
        dvr.notes,
      ].join(' ').toLowerCase();

      return haystack.contains(_searchQuery);
    }).toList();
  }
}

class _HeroCard extends StatelessWidget {
  final int dvrCount;
  final int onlineDvrCount;
  final int cameraCount;
  final int onlineCameraCount;
  final bool isSyncing;
  final VoidCallback onOpenCompanionApp;

  const _HeroCard({
    required this.dvrCount,
    required this.onlineDvrCount,
    required this.cameraCount,
    required this.onlineCameraCount,
    required this.isSyncing,
    required this.onOpenCompanionApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF3A63C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isSyncing ? 'Synchronisation...' : 'Supervision temps réel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Le manager peut piloter les DVR, suivre les flux live et ouvrir les enregistrements des caméras.',
            style: TextStyle(
              color: Colors.white,
              height: 1.45,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  value: '$dvrCount',
                  label: 'DVR',
                ),
              ),
              Expanded(
                child: _HeroMetric(
                  value: '$onlineDvrCount',
                  label: 'En service',
                ),
              ),
              Expanded(
                child: _HeroMetric(
                  value: '$onlineCameraCount/$cameraCount',
                  label: 'Caméras live',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onOpenCompanionApp,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Ouvrir IronGrid Surveillance'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Lance l app compagnon pour afficher toutes les cameras, le mur video et les archives en mode dedie.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeroMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class ModeBanner extends StatelessWidget {
  final bool isUsingDemoData;
  final String? message;

  const ModeBanner({
    super.key,
    required this.isUsingDemoData,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isUsingDemoData ? const Color(0xFFF59E0B) : const Color(0xFF16A34A);

    final title = isUsingDemoData
        ? 'Mode local de démonstration'
        : 'Backend caméras connecté';

    final text = message ??
        (isUsingDemoData
            ? 'Les écrans sont prêts. Il suffira de brancher les vraies APIs dans manager_surveillance_api_service.dart.'
            : 'Les DVR et les caméras viennent maintenant du backend.');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DvrCard extends StatelessWidget {
  final ManagerDvr dvr;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DvrCard({
    required this.dvr,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(dvr.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dvr.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dvr.site,
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dvr.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoTag(icon: Icons.router_outlined, label: dvr.networkAddress),
              _InfoTag(
                icon: Icons.swap_horiz_outlined,
                label: dvr.protocol.toUpperCase(),
              ),
              _InfoTag(icon: Icons.hd_outlined, label: dvr.streamProfile),
              _InfoTag(
                icon: Icons.fiber_manual_record_rounded,
                label: '${dvr.recordingCameras} enregistrements',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Caméras',
                  value: '${dvr.totalCameras}',
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'Live',
                  value: '${dvr.onlineCameras}',
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'Disponibilité',
                  value: '${(dvr.availabilityRatio * 100).round()}%',
                ),
              ),
            ],
          ),
          if (dvr.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              dvr.notes,
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.95),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onView,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.live_tv_outlined),
                  label: const Text('Ouvrir'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTag({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 68,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'Aucun DVR trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoute un équipement ou connecte le backend caméras pour charger les flux de surveillance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.92),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Créer un DVR'),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'online':
      return const Color(0xFF16A34A);
    case 'degraded':
      return const Color(0xFFF59E0B);
    case 'offline':
      return const Color(0xFFEF4444);
    default:
      return AppColors.textMuted;
  }
}
