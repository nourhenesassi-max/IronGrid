import 'package:flutter/material.dart';
import '../../data/manager_repository.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/manager_project_model.dart';

class ManagerEditProjectScreen extends StatefulWidget {
  final ManagerProjectModel project;

  const ManagerEditProjectScreen({
    super.key,
    required this.project,
  });

  @override
  State<ManagerEditProjectScreen> createState() =>
      _ManagerEditProjectScreenState();
}

class _ManagerEditProjectScreenState extends State<ManagerEditProjectScreen> {
  final ManagerRepository _repo = ManagerRepository();

  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _projectDeadlineController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _employeeSearchController =
      TextEditingController();

  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  String _selectedPriority = 'Moyenne';
  List<ProjectTaskModel> _projectTasks = [];

  bool _loadingEmployees = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _projectController.text = widget.project.projectName;
    _projectDeadlineController.text = widget.project.deadline;
    _descriptionController.text = widget.project.description;
    _selectedPriority = widget.project.priority;
    _projectTasks = List<ProjectTaskModel>.from(widget.project.tasks);
    _loadEmployees();
  }

  @override
  void dispose() {
    _projectController.dispose();
    _projectDeadlineController.dispose();
    _descriptionController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await _repo.getEmployees();

      EmployeeModel? selected;
      for (final employee in employees) {
        if (employee.name.trim().toLowerCase() ==
            widget.project.employeeName.trim().toLowerCase()) {
          selected = employee;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _employees = employees;
        _selectedEmployee = selected;
        _loadingEmployees = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingEmployees = false;
      });

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
      firstDate: DateTime(now.year - 1),
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
                      color: Colors.grey,
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
                            child: Text('Aucun employé trouvé.'),
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

  Future<void> _addTask() async {
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

    final result = await showDialog<ProjectTaskModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une tâche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: _inputDecoration('Nom de la tâche'),
              ),
              const SizedBox(height: 12),
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

  Future<void> _editTask(int index) async {
    final task = _projectTasks[index];
    final titleController = TextEditingController(text: task.title);
    final deadlineController = TextEditingController(text: task.deadline);
    bool isCompleted = task.isCompleted;

    final result = await showDialog<ProjectTaskModel>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Modifier la tâche'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: _inputDecoration('Nom de la tâche'),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isCompleted,
                      title: const Text('Tâche terminée'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setDialogState(() {
                          isCompleted = value;
                        });
                      },
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
                        id: task.id,
                        title: titleController.text.trim(),
                        deadline: deadlineController.text.trim(),
                        isCompleted: isCompleted,
                      ),
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _projectTasks[index] = result;
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _projectTasks.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    if (_projectController.text.trim().isEmpty ||
        _selectedEmployee == null ||
        _projectDeadlineController.text.trim().isEmpty ||
        _projectTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs et garder au moins une tâche.',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        _saving = true;
      });

      await _repo.updateProject(
        projectId: widget.project.id,
        projectName: _projectController.text.trim(),
        employeeId: _selectedEmployee!.id,
        deadline: _projectDeadlineController.text.trim(),
        priority: _selectedPriority,
        description: _descriptionController.text.trim(),
        tasks: _projectTasks,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet modifié avec succès.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur modification projet: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _buildTaskTile(ProjectTaskModel task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.deadline,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.isCompleted ? 'Terminée' : 'En cours',
                  style: TextStyle(
                    color: task.isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editTask(index),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => _removeTask(index),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          ),
        ],
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
          'Modifier le projet',
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
                TextField(
                  controller: _projectController,
                  decoration: _inputDecoration('Nom du projet'),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _showEmployeesSheet,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          color: Color(0xFF4F46E5),
                        ),
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
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration('Description'),
                ),
                const SizedBox(height: 22),
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
                      onPressed: _addTask,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_projectTasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('Aucune tâche dans ce projet.'),
                  )
                else
                  ..._projectTasks.asMap().entries.map(
                        (entry) => _buildTaskTile(entry.value, entry.key),
                      ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Text(
                            'Enregistrer les modifications',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}