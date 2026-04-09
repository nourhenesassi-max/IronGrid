import 'package:flutter/material.dart';
import '../../data/employee_repository.dart';
import '../../data/models/employee_models.dart';

class EmployeeTimesheetScreen extends StatefulWidget {
  const EmployeeTimesheetScreen({super.key});

  @override
  State<EmployeeTimesheetScreen> createState() =>
      _EmployeeTimesheetScreenState();
}

class _EmployeeTimesheetScreenState extends State<EmployeeTimesheetScreen> {
  final EmployeeRepository _repo = EmployeeRepository();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _pauseController =
      TextEditingController(text: '2');

  List<EmployeeProject> _projects = [];
  EmployeeProject? _selectedProject;
  ProjectTask? _selectedTask;

  bool _loadingProjects = true;
  String? _projectsError;

  double workedHours = 0;
  String result = 'Remplissez le formulaire.';
  Color resultColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _repo.getAssignedProjects();
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _loadingProjects = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _projectsError = e.toString();
        _loadingProjects = false;
      });
    }
  }

  bool _isSunday(String dateText) {
    try {
      final date = DateTime.parse(dateText);
      return date.weekday == DateTime.sunday;
    } catch (_) {
      return false;
    }
  }

  void _calculateHours() {
    try {
      if (_dateController.text.trim().isEmpty ||
          _selectedProject == null ||
          _selectedTask == null ||
          _startController.text.trim().isEmpty ||
          _endController.text.trim().isEmpty) {
        setState(() {
          result = 'Veuillez remplir tous les champs.';
          resultColor = Colors.red;
        });
        return;
      }

      if (_isSunday(_dateController.text.trim())) {
        setState(() {
          workedHours = 0;
          result = 'Dimanche : jour non travaillé.';
          resultColor = Colors.orange;
        });
        return;
      }

      final start = _startController.text.split(':');
      final end = _endController.text.split(':');

      final startHour = int.parse(start[0]) + int.parse(start[1]) / 60;
      final endHour = int.parse(end[0]) + int.parse(end[1]) / 60;
      final pause = double.tryParse(_pauseController.text) ?? 2;

      final total = endHour - startHour - pause;

      setState(() {
        workedHours = total > 0 ? total : 0;

        if (workedHours < 7) {
          result = 'Heures insuffisantes : ${workedHours.toStringAsFixed(1)} h';
          resultColor = Colors.red;
        } else if (workedHours > 9) {
          result = 'Heures dépassées : ${workedHours.toStringAsFixed(1)} h';
          resultColor = Colors.red;
        } else {
          result = 'Journée valide : ${workedHours.toStringAsFixed(1)} h';
          resultColor = Colors.green;
        }
      });
    } catch (_) {
      setState(() {
        result = 'Entrée invalide';
        resultColor = Colors.red;
      });
    }
  }

  void _saveTimesheet() {
    if (_selectedProject == null ||
        _selectedTask == null ||
        _dateController.text.trim().isEmpty ||
        _startController.text.trim().isEmpty ||
        _endController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez remplir tous les champs avant de sauvegarder.'),
        ),
      );
      return;
    }

    _calculateHours();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timesheet enregistré (backend à brancher ensuite).'),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    _pauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskList = _selectedProject?.tasks ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheet'),
      ),
      body: _loadingProjects
          ? const Center(child: CircularProgressIndicator())
          : _projectsError != null
              ? Center(child: Text('Erreur: $_projectsError'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _field('Date', _dateController, hint: '2026-03-07'),
                    const SizedBox(height: 12),
                    _dropdownField(
                      label: 'Projet',
                      child: DropdownButtonFormField<EmployeeProject>(
                        value: _selectedProject,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: const Text('Sélectionner un projet'),
                        items: _projects.map((project) {
                          return DropdownMenuItem<EmployeeProject>(
                            value: project,
                            child: Text(project.projectName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProject = value;
                            _selectedTask = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _dropdownField(
                      label: 'Tâche',
                      child: DropdownButtonFormField<ProjectTask>(
                        value: _selectedTask,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: const Text('Sélectionner une tâche'),
                        items: taskList.map((task) {
                          return DropdownMenuItem<ProjectTask>(
                            value: task,
                            child: Text(task.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTask = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field('Heure début', _startController, hint: '08:00'),
                    const SizedBox(height: 12),
                    _field('Heure fin', _endController, hint: '18:00'),
                    const SizedBox(height: 12),
                    _field('Pause (heures)', _pauseController, hint: '2'),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _calculateHours,
                            child: const Text('Calculer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveTimesheet,
                            child: const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        result,
                        style: TextStyle(
                          color: resultColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_selectedProject != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Projet sélectionné',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text('Nom: ${_selectedProject!.projectName}'),
                              Text('Manager: ${_selectedProject!.managerName}'),
                              Text('Deadline: ${_selectedProject!.deadline}'),
                              Text('Priorité: ${_selectedProject!.priority}'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}