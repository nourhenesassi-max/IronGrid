import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../data/admin_service.dart';

class RejectedUsersScreen extends StatefulWidget {
  const RejectedUsersScreen({super.key});

  @override
  State<RejectedUsersScreen> createState() => _RejectedUsersScreenState();
}

class _RejectedUsersScreenState extends State<RejectedUsersScreen> {
  final AdminService _adminService = AdminService();

  bool _loading = true;
  List<RejectedUser> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
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

  String _cleanErrorMessage(Object e) {
    return e.toString().replaceFirst('Exception: ', '').trim();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await _adminService.getRejectedUsers();
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

  Future<void> _deleteAllRejected() async {
    if (_users.isEmpty) {
      _snack('Aucun utilisateur rejeté à supprimer');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Supprimer la liste',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Voulez-vous supprimer tous les comptes rejetés ?',
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

    if (confirmed != true) return;

    try {
      final message = await _adminService.deleteAllRejectedUsers();
      _snack(message);
      await _loadUsers();
    } catch (e) {
      _snack(_cleanErrorMessage(e));
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'rejected':
      case 'refusé':
      case 'refuse':
        return Colors.red;
      case 'pending':
      case 'en attente':
        return Colors.orange;
      case 'approved':
      case 'accepté':
      case 'accepte':
        return Colors.green;
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

  Widget _buildUserCard(RejectedUser user) {
    final displayName = user.fullName.isEmpty ? 'Sans nom' : user.fullName;
    final statusColor = _statusColor(user.status);

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
                    backgroundColor: Colors.red.withOpacity(0.10),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName.trim()[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
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
                            letterSpacing: 0.2,
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                runSpacing: 10,
                spacing: 10,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _buildInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: user.phone ?? '-',
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Adresse',
                      value: user.address ?? '-',
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: _buildInfoTile(
                      icon: Icons.groups_outlined,
                      label: 'Équipe',
                      value: user.teamLabel ?? '-',
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: _buildInfoTile(
                      icon: Icons.folder_open_outlined,
                      label: 'Projet',
                      value: user.projectLabel ?? '-',
                    ),
                  ),
                ],
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
            Colors.red.shade700,
            Colors.deepOrange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_off_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Utilisateurs rejetés',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_users.length} utilisateur${_users.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadUsers,
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.red.withOpacity(0.08),
                  child: const Icon(
                    Icons.person_search_outlined,
                    size: 34,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun utilisateur rejeté',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tirez vers le bas pour actualiser la liste.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Utilisateurs rejetés',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Supprimer la liste',
            onPressed: _deleteAllRejected,
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingState()
          : _users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _users.length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) return _buildHeader();

                      final user = _users[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildUserCard(user),
                      );
                    },
                  ),
                ),
    );
  }
}