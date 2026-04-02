import 'package:flutter/material.dart';

import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_surveillance_model.dart';
import '../../data/services/manager_surveillance_store.dart';
import '../widgets/manager_camera_status_card.dart';
import '../widgets/manager_camera_stream_panel.dart';
import '../widgets/manager_dvr_summary_card.dart';
import 'manager_dvr_form_screen.dart';

class ManagerDvrDetailScreen extends StatefulWidget {
  final String dvrId;

  const ManagerDvrDetailScreen({
    super.key,
    required this.dvrId,
  });

  @override
  State<ManagerDvrDetailScreen> createState() => _ManagerDvrDetailScreenState();
}

class _ManagerDvrDetailScreenState extends State<ManagerDvrDetailScreen> {
  final ManagerSurveillanceStore _store = ManagerSurveillanceStore.instance;
  final Set<String> _busyCameraIds = <String>{};
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _store.ensureLoaded();
  }

  Future<void> _editDvr(ManagerDvr dvr) async {
    final updated = await Navigator.push<ManagerDvr>(
      context,
      MaterialPageRoute<ManagerDvr>(
        builder: (_) => ManagerDvrFormScreen(initialDvr: dvr),
      ),
    );

    if (updated == null) {
      return;
    }

    try {
      await _store.updateDvr(updated);
    } catch (error) {
      _showMessage(error.toString());
      return;
    }

    _showMessage('DVR mis a jour avec succes.');
  }

  Future<void> _toggleCameraStatus(
    ManagerCameraFeed camera,
    bool isOnline,
  ) async {
    if (_busyCameraIds.contains(camera.id)) {
      return;
    }

    setState(() {
      _busyCameraIds.add(camera.id);
    });

    try {
      await _store.updateCameraStatus(
        cameraId: camera.id,
        isOnline: isOnline,
      );
      _showMessage(
        isOnline
            ? '${camera.name} est maintenant en ligne.'
            : '${camera.name} est maintenant hors ligne.',
      );
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busyCameraIds.remove(camera.id);
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Supervision DVR',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 19,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
        body: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return ValueListenableBuilder<List<ManagerDvr>>(
              valueListenable: _store.dvrs,
              builder: (context, _, __) {
                final dvr = _store.getById(widget.dvrId);

                if (dvr == null) {
                  return const Center(
                    child: Text(
                      'DVR indisponible',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: ManagerDvrSummaryCard(
                        dvr: dvr,
                        onEdit: () => _editDvr(dvr),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const TabBar(
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textMuted,
                          dividerColor: Colors.transparent,
                          tabs: <Widget>[
                            Tab(text: 'Cameras'),
                            Tab(text: 'Streaming'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          _CameraListTab(
                            dvr: dvr,
                            busyCameraIds: _busyCameraIds,
                            onToggleStatus: _toggleCameraStatus,
                          ),
                          _StreamingTab(
                            dvr: dvr,
                            busyCameraIds: _busyCameraIds,
                            onToggleStatus: _toggleCameraStatus,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CameraListTab extends StatelessWidget {
  final ManagerDvr dvr;
  final Set<String> busyCameraIds;
  final Future<void> Function(ManagerCameraFeed camera, bool isOnline)
      onToggleStatus;

  const _CameraListTab({
    required this.dvr,
    required this.busyCameraIds,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (dvr.cameras.isEmpty) {
      return const Center(
        child: Text(
          'Aucune camera disponible',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: dvr.cameras.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final camera = dvr.cameras[index];
        return ManagerCameraStatusCard(
          camera: camera,
          isBusy: busyCameraIds.contains(camera.id),
          onToggleOnline: (value) => onToggleStatus(camera, value),
        );
      },
    );
  }
}

class _StreamingTab extends StatefulWidget {
  final ManagerDvr dvr;
  final Set<String> busyCameraIds;
  final Future<void> Function(ManagerCameraFeed camera, bool isOnline)
      onToggleStatus;

  const _StreamingTab({
    required this.dvr,
    required this.busyCameraIds,
    required this.onToggleStatus,
  });

  @override
  State<_StreamingTab> createState() => _StreamingTabState();
}

class _StreamingTabState extends State<_StreamingTab> {
  String? _selectedCameraId;

  @override
  void initState() {
    super.initState();
    if (widget.dvr.cameras.isNotEmpty) {
      _selectedCameraId = widget.dvr.cameras.first.id;
    }
  }

  @override
  void didUpdateWidget(covariant _StreamingTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dvr.cameras.isEmpty) {
      _selectedCameraId = null;
      return;
    }

    final stillExists = widget.dvr.cameras.any(
      (camera) => camera.id == _selectedCameraId,
    );

    if (!stillExists) {
      _selectedCameraId = widget.dvr.cameras.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dvr.cameras.isEmpty) {
      return const Center(
        child: Text(
          'Aucune camera disponible',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final camera = widget.dvr.cameras.firstWhere(
      (item) => item.id == _selectedCameraId,
      orElse: () => widget.dvr.cameras.first,
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        ManagerCameraStreamPanel(
          camera: camera,
          title: 'Flux live',
          actionLabel: 'Plein ecran',
          onOpenFullscreen: camera.hasLiveStream
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ManagerCameraPlaybackScreen(
                        title: '${camera.name} - Direct',
                        subtitle: widget.dvr.name,
                        sourceUrl: camera.streamUrl,
                      ),
                    ),
                  );
                }
              : null,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _InfoTile(
              label: 'Source',
              value: camera.streamType.toUpperCase(),
              icon: Icons.hub_outlined,
            ),
            _InfoTile(
              label: 'Resolution',
              value: camera.resolution,
              icon: Icons.hd_outlined,
            ),
            _InfoTile(
              label: 'Latence',
              value: camera.latencyLabel,
              icon: Icons.timer_outlined,
            ),
            _InfoTile(
              label: 'Enregistrement',
              value: camera.recordingEnabled ? 'Actif' : 'Arrete',
              icon: Icons.fiber_manual_record_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Controle de la camera',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                camera.isOnline
                    ? 'La camera est visible partout dans IronGrid et dans l application de supervision.'
                    : 'La camera est coupee pour toutes les vues connectees au backend.',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.94),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.busyCameraIds.contains(camera.id)
                          ? null
                          : () => widget.onToggleStatus(camera, !camera.isOnline),
                      icon: widget.busyCameraIds.contains(camera.id)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              camera.isOnline
                                  ? Icons.videocam_off_rounded
                                  : Icons.videocam_rounded,
                            ),
                      label: Text(
                        camera.isOnline ? 'Passer hors ligne' : 'Remettre en ligne',
                      ),
                    ),
                  ),
                  if (camera.hasArchive) ...<Widget>[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => ManagerCameraPlaybackScreen(
                                title: '${camera.name} - Archive',
                                subtitle: widget.dvr.name,
                                sourceUrl: camera.archiveUrl,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('Voir archive'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cameras du DVR',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.dvr.cameras.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = widget.dvr.cameras[index];
              final selected = item.id == camera.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCameraId = item.id;
                  });
                },
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 178,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.zone,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.82)
                              : AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.isOnline ? 'En ligne' : 'Hors ligne',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : (item.isOnline
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFDC2626)),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 162,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}
