import 'package:flutter/material.dart';
import '../../data/models/manager_leave_request.dart';
import '../../data/services/manager_leave_service.dart';

class ManagerLeaveRequestsScreen extends StatefulWidget {
  const ManagerLeaveRequestsScreen({super.key});

  @override
  State<ManagerLeaveRequestsScreen> createState() =>
      _ManagerLeaveRequestsScreenState();
}

class _ManagerLeaveRequestsScreenState
    extends State<ManagerLeaveRequestsScreen> {
  final _service = ManagerLeaveService();

  List<ManagerLeaveRequest> _requests = [];
  bool _loading = true;
  bool _actionLoading = false;
  String? _error;

  String _filter = "ALL";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getLeaveRequests(
        status: _filter == "ALL" ? null : _filter,
      );

      if (!mounted) return;

      setState(() {
        _requests = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _approve(int id) async {
    setState(() => _actionLoading = true);

    try {
      await _service.approveLeave(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande approuvée"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _reject(int id) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Refuser la demande"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Raison (optionnel)",
            filled: true,
            fillColor: const Color(0xFFF6F7FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFD92D20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Refuser"),
          ),
        ],
      ),
    );

    if (result == null) return;

    setState(() => _actionLoading = true);

    try {
      await _service.rejectLeave(id, reason: result);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande refusée"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "APPROVED":
        return const Color(0xFF16A34A);
      case "REJECTED":
        return const Color(0xFFDC2626);
      case "CANCELLED":
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "APPROVED":
        return "Approuvé";
      case "REJECTED":
        return "Refusé";
      case "CANCELLED":
        return "Annulé";
      default:
        return "En attente";
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "APPROVED":
        return Icons.check_circle_rounded;
      case "REJECTED":
        return Icons.cancel_rounded;
      case "CANCELLED":
        return Icons.remove_circle_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _requests.where((element) => element.status == "PENDING").length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        centerTitle: false,
        title: const Text(
          "Demandes de congés",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopHeader(pendingCount),
              _buildFilters(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
          if (_actionLoading)
            Container(
              color: Colors.black.withOpacity(0.08),
              child: const Center(
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                        SizedBox(width: 12),
                        Text("Traitement en cours..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(int pendingCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Suivi des demandes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pendingCount > 0
                      ? "$pendingCount demande(s) en attente de validation"
                      : "Toutes les demandes sont à jour",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECACA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 34,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Erreur de chargement",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Réessayer"),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 42,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(height: 14),
                Text(
                  "Aucune demande trouvée",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Les demandes correspondant au filtre sélectionné apparaîtront ici.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: _requests.length,
      itemBuilder: (_, i) => _buildRequestCard(_requests[i]),
    );
  }

  Widget _buildRequestCard(ManagerLeaveRequest r) {
    final statusColor = _statusColor(r.status);
    final hasComment = (r.managerComment ?? "").trim().isNotEmpty;
    final subtitle = r.employeeTeam.isEmpty
        ? r.leaveType
        : "${r.employeeTeam} • ${r.leaveType}";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEF2F7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(r, statusColor),
            const SizedBox(height: 14),
            _buildInfoRow(Icons.groups_rounded, subtitle),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.calendar_month_rounded,
              "${r.startDate} → ${r.endDate}",
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.timelapse_rounded, "${r.daysCount} jour(s)"),
            if (r.reason.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildSectionBox(
                icon: Icons.notes_rounded,
                title: "Motif",
                content: r.reason,
              ),
            ],
            if (hasComment) ...[
              const SizedBox(height: 12),
              _buildSectionBox(
                icon: Icons.comment_rounded,
                title: "Commentaire manager",
                content: r.managerComment!.trim(),
                background: const Color(0xFFF8FAFC),
              ),
            ],
            if (r.status == "PENDING") ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _actionLoading ? null : () => _approve(r.id),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text("Accepter"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _actionLoading ? null : () => _reject(r.id),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text("Refuser"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB42318),
                        side: const BorderSide(color: Color(0xFFFDA29B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(ManagerLeaveRequest r, Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFEFF6FF),
          child: Text(
            _initials(r.employeeName),
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.employeeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Demande de congé",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _statusIcon(r.status),
                size: 15,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                _statusLabel(r.status),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBox({
    required IconData icon,
    required String title,
    required String content,
    Color background = const Color(0xFFF9FAFB),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xFF475467)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _chip("Tous", "ALL"),
            _chip("En attente", "PENDING"),
            _chip("Approuvé", "APPROVED"),
            _chip("Refusé", "REJECTED"),
            _chip("Annulé", "CANCELLED"),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF334155),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2563EB),
        side: BorderSide(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        onSelected: (_) async {
          setState(() => _filter = value);
          await _load();
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}