import 'package:flutter/material.dart';
import 'package:irongrid_app/core/config/api_config.dart';
import '../../data/manager_repository.dart';
import 'package:irongrid_app/features/manager/data/models/employee_model.dart';
import '../widgets/manager_bottom_nav.dart';

class ManagerTeamScreen extends StatefulWidget {
  const ManagerTeamScreen({super.key});

  @override
  State<ManagerTeamScreen> createState() => _ManagerTeamScreenState();
}

class _ManagerTeamScreenState extends State<ManagerTeamScreen> {
  final ManagerRepository _repo = ManagerRepository();

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repo.getEmployees();
      if (!mounted) return;

      setState(() {
        _employees = data;
        _filteredEmployees = data;
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

  Future<void> _confirmRemoveEmployee(EmployeeModel emp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retirer de l’équipe'),
        content: Text(
          'Voulez-vous retirer ${_safeText(emp.name, fallback: "cet employé")} de votre équipe ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _removeEmployee(emp.id);
    }
  }

  Future<void> _removeEmployee(int employeeId) async {
    try {
      await _repo.removeEmployeeFromTeam(employeeId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employé retiré de l’équipe')),
      );

      await _loadEmployees();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((e) {
          return _safeText(e.name).toLowerCase().contains(query) ||
              _safeText(e.email).toLowerCase().contains(query) ||
              _safeText(e.teamLabel).toLowerCase().contains(query) ||
              _safeText(e.projectLabel).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _safeText(String? value, {String fallback = ''}) {
    if (value == null) return fallback;
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _initials(String? name) {
    final safeName = _safeText(name);
    final parts =
        safeName.split(' ').where((e) => e.trim().isNotEmpty).toList();

    if (parts.isEmpty) return 'E';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String? _employeeAvatarUrl(EmployeeModel emp) {
    final value = emp.avatarUrl;
    if (value == null) return null;

    final url = value.trim();
    if (url.isEmpty || url.toLowerCase() == 'null') return null;

    return ApiConfig.resolveUrl(url);
  }

  Widget _buildEmployeeAvatar(EmployeeModel emp) {
    final avatarUrl = _employeeAvatarUrl(emp);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.indigo.withOpacity(0.12),
      ),
      child: ClipOval(
        child: avatarUrl == null
            ? Center(
                child: Text(
                  _initials(emp.name),
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                width: 56,
                height: 56,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      _initials(emp.name),
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Mon équipe"),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.indigo,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un employé...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text("Erreur: $_error"))
                    : _filteredEmployees.isEmpty
                        ? const Center(child: Text("Aucun employé trouvé."))
                        : RefreshIndicator(
                            onRefresh: _loadEmployees,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredEmployees.length,
                              itemBuilder: (context, index) {
                                final emp = _filteredEmployees[index];
                                final name = _safeText(
                                  emp.name,
                                  fallback: 'Employé inconnu',
                                );
                                final email = _safeText(emp.email);
                                final teamLabel = _safeText(emp.teamLabel);
                                final projectLabel =
                                    _safeText(emp.projectLabel);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x12000000),
                                        blurRadius: 14,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        _buildEmployeeAvatar(emp),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                "/manager/employee",
                                                arguments: emp,
                                              );
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  email,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    if (teamLabel.isNotEmpty)
                                                      _TagChip(
                                                        icon: Icons
                                                            .groups_2_outlined,
                                                        text: teamLabel,
                                                      ),
                                                    if (projectLabel.isNotEmpty)
                                                      _TagChip(
                                                        icon:
                                                            Icons.work_outline,
                                                        text: projectLabel,
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          tooltip: 'Retirer',
                                          onPressed: () =>
                                              _confirmRemoveEmployee(emp),
                                          icon: const Icon(
                                            Icons.person_remove_alt_1_outlined,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.indigo.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 18,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: const ManagerBottomNav(currentIndex: 0),
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TagChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.indigo),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}
