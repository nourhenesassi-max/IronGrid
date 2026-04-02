import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../data/admin_service.dart';

class ApprovedUsersScreen extends StatefulWidget {
  const ApprovedUsersScreen({super.key});

  @override
  State<ApprovedUsersScreen> createState() => _ApprovedUsersScreenState();
}

class _ApprovedUsersScreenState extends State<ApprovedUsersScreen> {
  final AdminService _adminService = AdminService();

  bool _loading = true;
  List<ApprovedUser> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  String _cleanErrorMessage(Object e) {
    String msg = e.toString().trim();

    bool changed = true;
    while (changed) {
      final before = msg;

      msg = msg.replaceFirst(RegExp(r'^Exception:\s*'), '');
      msg = msg.replaceFirst(RegExp(r'^Erreur DELETE:\s*'), '');
      msg = msg.replaceFirst(RegExp(r'^Erreur GET:\s*'), '');
      msg = msg.replaceFirst(RegExp(r'^Erreur POST:\s*'), '');
      msg = msg.replaceFirst(RegExp(r'^Erreur PATCH:\s*'), '');
      msg = msg.replaceFirst(RegExp(r'^Erreur API \d+:\s*'), '');

      msg = msg.trim();
      changed = msg != before;
    }

    return msg;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await _adminService.getApprovedUsers();
      if (!mounted) return;
      setState(() => _users = users);
    } catch (e) {
      _snack(_cleanErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _confirmDelete(ApprovedUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Supprimer utilisateur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer '
          '${user.fullName.isEmpty ? user.email : user.fullName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteUser(user);
    }
  }

  Future<void> _deleteUser(ApprovedUser user) async {
    try {
      final message = await _adminService.deleteUser(user.id);

      if (!mounted) return;

      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });

      _snack(message);
    } catch (e) {
      _snack(_cleanErrorMessage(e));
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepté':
      case 'accepte':
        return Colors.green;
      case 'pending':
      case 'en attente':
        return Colors.orange;
      case 'rejected':
      case 'refusé':
      case 'refuse':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13.5,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value.isEmpty ? '-' : value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(ApprovedUser user) {
    final displayName = user.fullName.isEmpty ? 'Sans nom' : user.fullName;
    final statusColor = _statusColor(user.status);
    final isAdmin = (user.role ?? '').toLowerCase().trim() == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue.withOpacity(0.10),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName.trim()[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 👇 IMPORTANT FIX HERE
              Wrap(
                runSpacing: 10,
                spacing: 10,
                children: [
                  if (!isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: _buildInfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        value: user.phone ?? '-',
                      ),
                    ),
                  if (!isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: _buildInfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Adresse',
                        value: user.address ?? '-',
                      ),
                    ),
                  if (!isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: _buildInfoTile(
                        icon: Icons.groups_outlined,
                        label: 'Équipe',
                        value: user.teamLabel ?? '-',
                      ),
                    ),
                  if (!isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: _buildInfoTile(
                        icon: Icons.folder_open_outlined,
                        label: 'Projet',
                        value: user.projectLabel ?? '-',
                      ),
                    ),

                  // always show role
                  SizedBox(
                    width: double.infinity,
                    child: _buildInfoTile(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Rôle',
                      value: user.role ?? '-',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDelete(user),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Supprimer'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.indigo.shade500,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            '${_users.length} utilisateur(s)',
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Aucun utilisateur accepté'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: _loading
          ? _buildLoadingState()
          : _users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: _users.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) return _buildHeader();

                      final user = _users[index - 1];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildUserCard(user),
                      );
                    },
                  ),
                ),
    );
  }
}