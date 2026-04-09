import 'package:flutter/material.dart';
import '../../data/employee_repository.dart';
import '../../data/models/employee_models.dart';

class EmployeeProjectsScreen extends StatefulWidget {
  const EmployeeProjectsScreen({super.key});

  @override
  State<EmployeeProjectsScreen> createState() => _EmployeeProjectsScreenState();
}

class _EmployeeProjectsScreenState extends State<EmployeeProjectsScreen> {
  final EmployeeRepository _repo = EmployeeRepository();

  bool _loading = true;
  String? _error;
  List<EmployeeProject> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _repo.getAssignedProjects();
      setState(() {
        _projects = projects;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'haute':
        return Colors.red;
      case 'medium':
      case 'moyenne':
        return Colors.orange;
      case 'low':
      case 'faible':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return Colors.blue;
      case 'en attente':
      case 'à faire':
        return Colors.orange;
      case 'terminé':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Projets'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : _projects.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun projet assigné.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _projects.length,
                        itemBuilder: (context, index) {
                          final project = _projects[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/employe-project-details',
                                arguments: project,
                              );
                            },
                            child: Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            project.projectName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Manager: ${project.managerName}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.event_outlined,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Deadline: ${project.deadline}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _TagChip(
                                          label: project.priority,
                                          color:
                                              _priorityColor(project.priority),
                                        ),
                                        _TagChip(
                                          label: project.status,
                                          color: _statusColor(project.status),
                                        ),
                                        _TagChip(
                                          label:
                                              '${project.tasks.length} tâches',
                                          color: Colors.indigo,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}