import 'package:flutter/material.dart';
import '../../data/manager_repository.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/manager_project_model.dart';

class ManagerAssignTaskScreen extends StatefulWidget {
  const ManagerAssignTaskScreen({super.key});

  @override
  State<ManagerAssignTaskScreen> createState() =>
      _ManagerAssignTaskScreenState();
}

class _ManagerAssignTaskScreenState extends State<ManagerAssignTaskScreen> {
  final ManagerRepository _repo = ManagerRepository();

  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _projectDeadlineController =
      TextEditingController();
  final TextEditingController _taskTemplateController = TextEditingController();
  final TextEditingController _employeeSearchController =
      TextEditingController();

  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  String _selectedPriority = 'Moyenne';

  /// Reusable task titles that the manager can save and use again
  final List<String> _savedTaskTemplates = [
    'Analyse des besoins',
    'Conception UI',
    'Développement backend',
    'Tests fonctionnels',
  ];

  /// Real tasks selected for the current project
  final List<ProjectTaskModel> _projectTasks = [];

  bool _loadingEmployees = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _projectController.dispose();
    _projectDeadlineController.dispose();
    _taskTemplateController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await _repo.getEmployees();
      setState(() {
        _employees = employees;
        _loadingEmployees = false;
      });
    } catch (e) {
      setState(() {
        _loadingEmployees = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement employés: $e')),
      );
    }
  }

  Future<String?> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return null;

    return '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickProjectDate() async {
    final date = await _pickDate();
    if (date == null) return;
    _projectDeadlineController.text = date;
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'élevée':
        return const Color(0xFFE53935);
      case 'moyenne':
        return const Color(0xFFFB8C00);
      case 'faible':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _priorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'élevée':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'moyenne':
        return Icons.remove_rounded;
      case 'faible':
        return Icons.keyboard_double_arrow_down_rounded;
      default:
        return Icons.flag_outlined;
    }
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.4),
      ),
    );
  }

  void _saveTaskTemplate() {
    final value = _taskTemplateController.text.trim();
    if (value.isEmpty) return;

    final alreadyExists = _savedTaskTemplates.any(
      (task) => task.toLowerCase() == value.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cette tâche existe déjà.')),
      );
      return;
    }

    setState(() {
      _savedTaskTemplates.insert(0, value);
      _taskTemplateController.clear();
    });
  }

  void _removeSavedTemplate(String taskTitle) {
    setState(() {
      _savedTaskTemplates.remove(taskTitle);
    });
  }

  Future<void> _addTaskToProjectFromTemplate(String taskTitle) async {
    final deadline = await _pickDate();
    if (deadline == null) return;

    setState(() {
      _projectTasks.add(
        ProjectTaskModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: taskTitle,
          deadline: deadline,
          isCompleted: false,
        ),
      );
    });
  }

  Future<void> _showCreateCustomTaskDialog() async {
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

    final result = await showDialog<ProjectTaskModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Ajouter une tâche personnalisée',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: _inputDecoration('Nom de la tâche'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: deadlineController,
                  readOnly: true,
                  onTap: () async {
                    final date = await _pickDate();
                    if (date != null) {
                      deadlineController.text = date;
                    }
                  },
                  decoration: _inputDecoration(
                    'Deadline tâche',
                    suffixIcon: const Icon(Icons.calendar_month_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    deadlineController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  ProjectTaskModel(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    deadline: deadlineController.text.trim(),
                    isCompleted: false,
                  ),
                );
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _projectTasks.add(result);
      });
    }
  }

  void _removeProjectTask(int index) {
    setState(() {
      _projectTasks.removeAt(index);
    });
  }

  Future<void> _showEmployeesSheet() async {
    _employeeSearchController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<EmployeeModel> filteredEmployees = List.from(_employees);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterEmployees(String query) {
              setModalState(() {
                filteredEmployees = _employees.where((employee) {
                  return employee.name
                      .toLowerCase()
                      .contains(query.toLowerCase());
                }).toList();
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Liste des employés',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _employeeSearchController,
                      onChanged: filterEmployees,
                      decoration: _inputDecoration(
                        'Rechercher un employé',
                        suffixIcon: const Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: filteredEmployees.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun employé trouvé.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = filteredEmployees[index];
                              final isSelected =
                                  _selectedEmployee?.id == employee.id;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF4F46E5)
                                        : Colors.grey.shade200,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF4F46E5)
                                        .withOpacity(0.1),
                                    child: Text(
                                      employee.name.isNotEmpty
                                          ? employee.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xFF4F46E5),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    employee.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF4F46E5),
                                        )
                                      : const Icon(Icons.chevron_right_rounded),
                                  onTap: () {
                                    setState(() {
                                      _selectedEmployee = employee;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveProject() async {
    if (_projectController.text.trim().isEmpty ||
        _selectedEmployee == null ||
        _projectDeadlineController.text.trim().isEmpty ||
        _projectTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs et ajouter au moins une tâche.',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        _saving = true;
      });

      await _repo.assignProject(
        projectName: _projectController.text.trim(),
        employeeId: _selectedEmployee!.id,
        deadline: _projectDeadlineController.text.trim(),
        priority: _selectedPriority,
        tasks: _projectTasks,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet assigné avec succès.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’envoi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Affectation de projet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Créer des projets de manière professionnelle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sélectionnez un employé, définissez la priorité, réutilisez des tâches enregistrées et attribuez une date limite à chaque tâche..',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    final color = _priorityColor(_selectedPriority);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _projectController,
            decoration: _inputDecoration('Nom du projet'),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _showEmployeesSheet,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_outlined, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedEmployee?.name ?? 'Choisir un employé',
                      style: TextStyle(
                        color: _selectedEmployee == null
                            ? Colors.grey.shade600
                            : const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _projectDeadlineController,
            readOnly: true,
            onTap: _pickProjectDate,
            decoration: _inputDecoration(
              'Deadline projet',
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: _inputDecoration('Priorité'),
            items: const [
              DropdownMenuItem(value: 'Faible', child: Text('Faible')),
              DropdownMenuItem(value: 'Moyenne', child: Text('Moyenne')),
              DropdownMenuItem(value: 'Élevée', child: Text('Élevée')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedPriority = value;
              });
            },
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_priorityIcon(_selectedPriority),
                      color: color, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Priority: $_selectedPriority',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskLibraryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bibliothèque des tâches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Écrivez une tâche une seule fois, sauvegardez-la, puis réutilisez-la dans d’autres projets.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskTemplateController,
                  decoration: _inputDecoration('Nouvelle tâche modèle'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveTaskTemplate,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_savedTaskTemplates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Aucune tâche sauvegardée.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ..._savedTaskTemplates.map(
              (taskTitle) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.task_alt_rounded,
                      color: Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        taskTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ajouter au projet',
                      onPressed: () => _addTaskToProjectFromTemplate(taskTitle),
                      icon: const Icon(
                        Icons.playlist_add_circle_rounded,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer',
                      onPressed: () => _removeSavedTemplate(taskTitle),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectTasksCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tâches du projet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateCustomTaskDialog,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Tâche perso'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Quand vous choisissez une tâche pour le projet, vous lui donnez sa propre deadline.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          if (_projectTasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Aucune tâche ajoutée au projet.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ..._projectTasks.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final task = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
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
                                Text(
                                  task.deadline,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeProjectTask(index),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: _saving ? null : _saveProject,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF111827),
          foregroundColor: Colors.white,
        ),
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Assigner le projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
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
        backgroundColor: const Color(0xFFF6F7FB),
        centerTitle: true,
        title: const Text(
          'Assigner un projet',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: _loadingEmployees
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                _buildProjectInfoCard(),
                const SizedBox(height: 18),
                _buildTaskLibraryCard(),
                const SizedBox(height: 18),
                _buildProjectTasksCard(),
                const SizedBox(height: 22),
                _buildSaveButton(),
              ],
            ),
    );
  }
}