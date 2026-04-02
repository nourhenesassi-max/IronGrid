import 'package:flutter/material.dart';
import '../../data/manager_repository.dart';
import '../../data/models/employee_model.dart';

class ManagerSendNotificationScreen extends StatefulWidget {
  const ManagerSendNotificationScreen({super.key});

  @override
  State<ManagerSendNotificationScreen> createState() =>
      _ManagerSendNotificationScreenState();
}

class _ManagerSendNotificationScreenState
    extends State<ManagerSendNotificationScreen> {
  final ManagerRepository _repo = ManagerRepository();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;

  bool _loadingEmployees = true;
  bool _sending = false;

  String _selectedType = 'TASK_ASSIGNED';

  final List<String> _types = [
    'PROJECT_ASSIGNED',
    'TASK_ASSIGNED',
    'PROJECT_UPDATED',
    'DEADLINE_REMINDER',
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await _repo.getEmployees();

      if (!mounted) return;
      setState(() {
        _employees = employees;
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

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'PROJECT_ASSIGNED':
        return 'Projet assigné';
      case 'TASK_ASSIGNED':
        return 'Tâche assignée';
      case 'PROJECT_UPDATED':
        return 'Projet mis à jour';
      case 'DEADLINE_REMINDER':
        return 'Rappel deadline';
      default:
        return type;
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty || _selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs.'),
        ),
      );
      return;
    }

    try {
      setState(() {
        _sending = true;
      });

      await _repo.sendNotification(
        title: title,
        content: content,
        type: _selectedType,
        receiverId: _selectedEmployee!.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification envoyée avec succès.'),
        ),
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
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envoyer une notification'),
      ),
      body: _loadingEmployees
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleController,
                  decoration: _inputDecoration('Titre'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: _inputDecoration('Message'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: _inputDecoration('Type'),
                  items: _types
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(_typeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<EmployeeModel>(
                  value: _selectedEmployee,
                  decoration: _inputDecoration('Employé'),
                  items: _employees
                      .map(
                        (employee) => DropdownMenuItem<EmployeeModel>(
                          value: employee,
                          child: Text(employee.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployee = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _sendNotification,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_sending ? 'Envoi...' : 'Envoyer'),
                  ),
                ),
              ],
            ),
    );
  }
}