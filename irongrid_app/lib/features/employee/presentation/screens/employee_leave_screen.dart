import 'package:flutter/material.dart';
import '../../data/leave_service.dart';
import '../../data/models/leave_models.dart';
import 'employee_new_leave_screen.dart';

class EmployeeLeaveScreen extends StatefulWidget {
  final bool acceptedOnly;

  const EmployeeLeaveScreen({
    super.key,
    this.acceptedOnly = false,
  });

  @override
  State<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends State<EmployeeLeaveScreen> {
  final LeaveService _leaveService = LeaveService();

  bool _loading = true;
  String? _error;
  LeaveStatsResponse? _stats;
  List<LeaveResponse> _leaves = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final stats = await _leaveService.getStats();
      final leaves = await _leaveService.getMine();

      if (!mounted) return;

      final filteredLeaves = widget.acceptedOnly
          ? leaves.where((e) => e.status.toUpperCase() == "APPROVED").toList()
          : leaves;

      setState(() {
        _stats = stats;
        _leaves = filteredLeaves;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _newLeave() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmployeeNewLeaveScreen()),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _cancelLeave(int id) async {
    try {
      await _leaveService.cancelLeave(id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande annulée")),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case "ANNUAL":
        return "Congé annuel";
      case "SICK":
        return "Congé maladie";
      case "UNPAID":
        return "Sans solde";
      case "MATERNITY":
        return "Maternité";
      case "PATERNITY":
        return "Paternité";
      default:
        return "Autre";
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return "Approuvé";
      case "REJECTED":
        return "Refusé";
      case "CANCELLED":
        return "Annulé";
      case "PENDING":
      default:
        return "En attente";
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return const Color(0xFF1E8E5A);
      case "REJECTED":
        return const Color(0xFFD93025);
      case "CANCELLED":
        return const Color(0xFF6B7280);
      case "PENDING":
      default:
        return const Color(0xFFE07A00);
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case "ANNUAL":
        return Icons.beach_access_rounded;
      case "SICK":
        return Icons.local_hospital_rounded;
      case "UNPAID":
        return Icons.account_balance_wallet_outlined;
      case "MATERNITY":
        return Icons.child_friendly_rounded;
      case "PATERNITY":
        return Icons.family_restroom_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  String _formatDate(String raw) {
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  Future<void> _confirmCancel(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Annuler la demande"),
        content: const Text(
          "Voulez-vous vraiment annuler cette demande de congé ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _cancelLeave(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle =
        widget.acceptedOnly ? "Mes congés approuvés" : "Mes congés";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF6F8FC),
        title: Text(
          screenTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: _loadData,
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.acceptedOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: _newLeave,
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                "Nouvelle demande",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(
                  message: _error!,
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (_stats != null && !widget.acceptedOnly) ...[
                        _LeaveOverviewCard(stats: _stats!),
                        const SizedBox(height: 20),
                      ],
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.acceptedOnly
                                ? "Liste des congés approuvés"
                                : "Mes demandes",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_leaves.isEmpty)
                        _EmptyLeaveState(
                          acceptedOnly: widget.acceptedOnly,
                          onCreate: widget.acceptedOnly ? null : _newLeave,
                        )
                      else
                        ..._leaves.map((leave) {
                          final statusColor = _statusColor(leave.status);
                          final statusLabel = _statusLabel(leave.status);
                          final canCancel = !widget.acceptedOnly &&
                              leave.status.toUpperCase() == "PENDING";

                          return _LeaveCard(
                            title: _typeLabel(leave.type),
                            icon: _typeIcon(leave.type),
                            statusLabel: statusLabel,
                            statusColor: statusColor,
                            period:
                                "Du ${_formatDate(leave.startDate)} au ${_formatDate(leave.endDate)}",
                            reason: leave.reason,
                            canCancel: canCancel,
                            onCancel: canCancel
                                ? () => _confirmCancel(leave.id)
                                : null,
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

class _LeaveOverviewCard extends StatelessWidget {
  final LeaveStatsResponse stats;

  const _LeaveOverviewCard({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final pendingLabel =
        "${stats.pendingCount} ${stats.pendingCount > 1 ? 'demandes' : 'demande'}";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F2563EB),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vue d’ensemble",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Suivez vos soldes et vos demandes en cours.",
            style: TextStyle(
              color: Color(0xFFDCE8FF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _OverviewMiniCard(
                  title: "${stats.annualDaysRemaining} jours",
                  subtitle: "Congés annuels",
                  icon: Icons.beach_access_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewMiniCard(
                  title: "${stats.sickDaysRemaining} jours",
                  subtitle: "Congés maladie",
                  icon: Icons.local_hospital_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "$pendingLabel en attente",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
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

class _OverviewMiniCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OverviewMiniCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFDCE8FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String statusLabel;
  final Color statusColor;
  final String period;
  final String? reason;
  final bool canCancel;
  final VoidCallback? onCancel;

  const _LeaveCard({
    required this.title,
    required this.icon,
    required this.statusLabel,
    required this.statusColor,
    required this.period,
    this.reason,
    required this.canCancel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              text: period,
            ),
            if (reason != null && reason!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.notes_rounded,
                text: reason!,
              ),
            ],
            if (canCancel) ...[
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD93025),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    "Annuler",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyLeaveState extends StatelessWidget {
  final bool acceptedOnly;
  final VoidCallback? onCreate;

  const _EmptyLeaveState({
    required this.acceptedOnly,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 32,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            acceptedOnly ? "Aucun congé approuvé" : "Aucune demande de congé",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            acceptedOnly
                ? "Vos congés approuvés apparaîtront ici."
                : "Créez votre première demande pour commencer.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!acceptedOnly && onCreate != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                "Nouvelle demande",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFD93025).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFD93025),
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Une erreur est survenue",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  "Réessayer",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}