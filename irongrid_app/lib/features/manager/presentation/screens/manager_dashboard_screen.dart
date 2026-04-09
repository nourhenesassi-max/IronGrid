import 'package:flutter/material.dart';
import '../../data/manager_repository.dart';
import '../../data/services/manager_message_repository.dart';
import '../../data/services/manager_leave_service.dart';
import '../widgets/alert_card.dart';
import '../widgets/kpi_box.dart';
import '../widgets/manager_badge_store.dart';
import '../widgets/manager_bottom_nav.dart';
import 'planification/planification_screen.dart';
import 'commercial/commercial_screen.dart';
import 'qualite/qualite_screen.dart';
import 'production/production_screen.dart';
import 'manager_leave_requests_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final ManagerRepository _repo = ManagerRepository();
  final ManagerMessageRepository _messageRepo = ManagerMessageRepository();
  final ManagerLeaveService _leaveService = ManagerLeaveService();

  int _employeeCount = 0;
  int _projectCount = 0;
  int _pendingLeaveCount = 0;

  bool _loadingEmployees = true;
  bool _loadingProjects = true;
  bool _loadingLeaves = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadProjects();
    _loadPendingLeaves();
    _loadMessageBadge();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await _repo.getEmployees();

      if (!mounted) return;

      setState(() {
        _employeeCount = employees.length;
        _loadingEmployees = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingEmployees = false;
      });
    }
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _repo.getProjects();

      if (!mounted) return;

      setState(() {
        _projectCount = projects.length;
        _loadingProjects = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingProjects = false;
      });
    }
  }

  Future<void> _loadPendingLeaves() async {
    try {
      final leaves = await _leaveService.getLeaveRequests(status: 'PENDING');

      if (!mounted) return;

      setState(() {
        _pendingLeaveCount = leaves.length;
        _loadingLeaves = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pendingLeaveCount = 0;
        _loadingLeaves = false;
      });
    }
  }

  Future<void> _loadMessageBadge() async {
    try {
      final conversations = await _messageRepo.getConversations();
      if (!mounted) return;

      int unreadTotal = 0;

      for (final conversation in conversations) {
        final dynamic c = conversation;

        try {
          final unreadCount = c.unreadCount;
          if (unreadCount is int) {
            unreadTotal += unreadCount;
            continue;
          }
          unreadTotal += int.tryParse(unreadCount.toString()) ?? 0;
          continue;
        } catch (_) {
          // fallback below
        }

        try {
          if (c.hasUnread == true) {
            unreadTotal += 1;
          }
        } catch (_) {
          // ignore malformed item
        }
      }

      ManagerBadgeStore.setUnreadMessages(unreadTotal);
    } catch (_) {
      ManagerBadgeStore.setUnreadMessages(0);
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadEmployees();
    await _loadProjects();
    await _loadPendingLeaves();
    await _loadMessageBadge();
  }

  Future<void> _openRoute(Future<dynamic> navigation) async {
    await navigation;
    if (!mounted) return;
    await _refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'title': 'Panne machine M-204',
        'description': 'Ligne de production arrêtée',
        'priority': 'Urgente',
      },
      {
        'title': 'Retard maintenance',
        'description': 'Intervention prévue non terminée',
        'priority': 'Moyenne',
      },
      {
        'title': 'Stock faible',
        'description': 'Matière première presque épuisée',
        'priority': 'Faible',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: const Text(
          'Tableau de bord Manager',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _openRoute(
                Navigator.pushNamed(context, '/manager/surveillance'),
              );
            },
            tooltip: 'Cameras',
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            onPressed: () async {
              await _openRoute(
                Navigator.pushNamed(context, '/manager/profile'),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(employeeCount: _employeeCount),
              const SizedBox(height: 20),
              const Text(
                'Indicateurs de performance',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _openRoute(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlanificationScreen(),
                          ),
                        ),
                      );
                    },
                    child: const KPIBox(
                      title: 'Gestion',
                      value: 'Planification',
                      icon: Icons.event_note_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _openRoute(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductionScreen(),
                          ),
                        ),
                      );
                    },
                    child: const KPIBox(
                      title: 'Opérations',
                      value: 'Production',
                      icon: Icons.precision_manufacturing_outlined,
                      color: Colors.green,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _openRoute(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QualiteScreen(),
                          ),
                        ),
                      );
                    },
                    child: const KPIBox(
                      title: 'Contrôle',
                      value: 'Qualité',
                      icon: Icons.verified_outlined,
                      color: Colors.purple,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _openRoute(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CommercialScreen(),
                          ),
                        ),
                      );
                    },
                    child: const KPIBox(
                      title: 'Ventes',
                      value: 'Commercial',
                      icon: Icons.attach_money_outlined,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Actions rapides',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    title: 'Assigner projet',
                    subtitle: 'Créer et assigner',
                    icon: Icons.assignment_outlined,
                    color: Colors.indigo,
                    onTap: () async {
                      await _openRoute(
                        Navigator.pushNamed(context, '/manager/assign_task'),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Projets',
                    subtitle: 'Voir tous les projets',
                    icon: Icons.folder_open_outlined,
                    color: Colors.blue,
                    badge: _loadingProjects ? '...' : _projectCount.toString(),
                    onTap: () async {
                      await _openRoute(
                        Navigator.pushNamed(context, '/manager/projects'),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Équipe',
                    subtitle: 'Gérer les membres',
                    icon: Icons.groups_2_outlined,
                    color: Colors.green,
                    badge:
                        _loadingEmployees ? '...' : _employeeCount.toString(),
                    onTap: () async {
                      await _openRoute(
                        Navigator.pushNamed(context, '/manager/team'),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Congés',
                    subtitle: 'Valider les demandes',
                    icon: Icons.event_busy_outlined,
                    color: const Color.fromARGB(255, 136, 113, 175),
                    badge:
                        _loadingLeaves ? '...' : _pendingLeaveCount.toString(),
                    onTap: () async {
                      await _openRoute(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerLeaveRequestsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Alertes récentes',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                itemCount: alerts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return AlertCard(
                    title: alert['title']!,
                    description: alert['description']!,
                    priority: alert['priority']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ManagerBottomNav(currentIndex: 0),
    );
  }
}

// ---------------- ACTION CARD ----------------

Widget _buildActionCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  String? badge,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.85), color],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// welcome

class _WelcomeCard extends StatelessWidget {
  final int employeeCount;

  const _WelcomeCard({required this.employeeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bonjour Manager ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suivez les performances de votre équipe ($employeeCount employés)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
