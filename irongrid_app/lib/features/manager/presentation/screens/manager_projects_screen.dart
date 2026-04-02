import 'package:flutter/material.dart';
import '../../data/manager_repository.dart';
import '../../data/models/manager_project_model.dart';
import 'manager_edit_project_screen.dart';

class ManagerProjectsScreen extends StatefulWidget {
  const ManagerProjectsScreen({super.key});

  @override
  State<ManagerProjectsScreen> createState() => _ManagerProjectsScreenState();
}

class _ManagerProjectsScreenState extends State<ManagerProjectsScreen> {
  final ManagerRepository _repo = ManagerRepository();

  List<ManagerProjectModel> _projects = [];
  bool _loading = true;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _repo.getProjects();
      setState(() {
        _projects = projects;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openEditProject(ManagerProjectModel project) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManagerEditProjectScreen(project: project),
      ),
    );

    if (result == true) {
      await _loadProjects();
    }
  }

  Future<void> _deleteProject(ManagerProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le projet'),
          content: Text(
            'Voulez-vous vraiment supprimer "${project.projectName}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _deleting = true;
      });

      await _repo.deleteProject(project.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet supprimé avec succès.')),
      );

      await _loadProjects();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur suppression projet: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'haute':
        return const Color(0xFFE53935);
      case 'medium':
      case 'moyenne':
        return const Color(0xFFFB8C00);
      case 'low':
      case 'faible':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _priorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'haute':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'medium':
      case 'moyenne':
        return Icons.remove_rounded;
      case 'low':
      case 'faible':
        return Icons.keyboard_double_arrow_down_rounded;
      default:
        return Icons.flag_outlined;
    }
  }

  int _completedTasksCount(List<dynamic> tasks) {
    int count = 0;

    for (final task in tasks) {
      if (task is String) continue;

      try {
        if ((task as dynamic).isCompleted == true) {
          count++;
        }
      } catch (_) {}
    }

    return count;
  }

  double _progressValue(List<dynamic> tasks) {
    if (tasks.isEmpty) return 0;
    return _completedTasksCount(tasks) / tasks.length;
  }

  String _taskTitle(dynamic task) {
    if (task is String) return task;

    try {
      return (task.title ?? '').toString();
    } catch (_) {
      return task.toString();
    }
  }

  String _taskDeadline(dynamic task) {
    if (task is String) return '';

    try {
      return (task.deadline ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  bool _taskCompleted(dynamic task) {
    if (task is String) return false;

    try {
      return (task.isCompleted ?? false) == true;
    } catch (_) {
      return false;
    }
  }

  String _projectDescription(ManagerProjectModel project) {
    try {
      final value = (project as dynamic).description;
      return value?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Widget _buildTopHeader() {
    final int totalProjects = _projects.length;
    final int totalTasks = _projects.fold(
      0,
      (sum, project) => sum + project.tasks.length,
    );
    final int completedTasks = _projects.fold(
      0,
      (sum, project) =>
          sum + _completedTasksCount(project.tasks.cast<dynamic>()),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manager Dashboard',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Projects overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  label: 'Projects',
                  value: totalProjects.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeaderStat(
                  label: 'Tasks',
                  value: totalTasks.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeaderStat(
                  label: 'Done',
                  value: completedTasks.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: chipColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(dynamic task) {
    final bool isCompleted = _taskCompleted(task);
    final String title = _taskTitle(task);
    final String deadline = _taskDeadline(task);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF1FFF5) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted ? const Color(0xFFB9E7C9) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF43A047).withOpacity(0.12)
                  : const Color(0xFFFB8C00).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: isCompleted
                  ? const Color(0xFF43A047)
                  : const Color(0xFFFB8C00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Untitled task' : title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        deadline.isNotEmpty ? deadline : 'No task deadline',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF43A047).withOpacity(0.10)
                        : const Color(0xFFFB8C00).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'In progress',
                    style: TextStyle(
                      color: isCompleted
                          ? const Color(0xFF43A047)
                          : const Color(0xFFFB8C00),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  Widget _buildProjectCard(ManagerProjectModel project) {
    final List<dynamic> tasks = project.tasks.cast<dynamic>();
    final double progress = _progressValue(tasks);
    final int completedCount = _completedTasksCount(tasks);
    final Color priorityColor = _priorityColor(project.priority);
    final String description = _projectDescription(project);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: Text(
            project.projectName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.person_outline_rounded,
                  text: project.employeeName,
                ),
                _buildInfoChip(
                  icon: Icons.calendar_today_rounded,
                  text: project.deadline,
                  color: const Color(0xFF4F46E5),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Modifier le projet',
                onPressed: () => _openEditProject(project),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF4F46E5),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_priorityIcon(project.priority),
                        size: 16, color: priorityColor),
                    const SizedBox(width: 4),
                    Text(
                      project.priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Supprimer le projet',
                onPressed: _deleting ? null : () => _deleteProject(project),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: _deleting ? Colors.grey : Colors.red,
                ),
              ),
            ],
          ),
          children: [
            if (description.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Text(
                  '$completedCount/${tasks.length} tasks',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.task_alt_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'No tasks in this project.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              ...tasks.map(_buildTaskCard),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProjects,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 62,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'No projects found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create projects and assign tasks with deadlines to your employees.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
        title: const Text(
          'Manager Projects',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _projects.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildTopHeader(),
                          const SizedBox(height: 18),
                          ..._projects.map(_buildProjectCard),
                        ],
                      ),
                    ),
    );
  }
}