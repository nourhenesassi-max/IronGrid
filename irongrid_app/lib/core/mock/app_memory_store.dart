import '../../features/employee/data/models/employee_models.dart';
import '../../features/manager/data/models/manager_models.dart';

class AppMemoryStore {
  AppMemoryStore._();
  static final AppMemoryStore instance = AppMemoryStore._();

  final List<ManagerAssignedProject> managerAssignedProjects = [
    ManagerAssignedProject(
      id: 'mp1',
      projectName: 'Website Redesign',
      employeeName: 'Ahmed Ben Ali',
      deadline: '20/03/2026',
      priority: 'High',
      tasks: ['UI Design', 'Landing Page'],
    ),
    ManagerAssignedProject(
      id: 'mp2',
      projectName: 'HR Portal Update',
      employeeName: 'Sara Trabelsi',
      deadline: '28/03/2026',
      priority: 'Medium',
      tasks: ['Employee Form', 'Dashboard Widgets'],
    ),
  ];

  final List<EmployeeNotification> employeeNotifications = [
    EmployeeNotification(
      id: 'n1',
      title: 'Nouveau projet assigné',
      message: 'Vous avez été affecté au projet Website Redesign.',
      time: 'Aujourd’hui',
      isRead: false,
    ),
    EmployeeNotification(
      id: 'n2',
      title: 'Deadline proche',
      message: 'La deadline du projet Website Redesign approche.',
      time: 'Il y a 2h',
      isRead: false,
    ),
  ];

  final List<TimesheetEntry> timesheetEntries = [
    TimesheetEntry(
      id: 'ts1',
      date: '2026-03-07',
      projectName: 'Website Redesign',
      taskName: 'Landing Page',
      startTime: '08:00',
      endTime: '18:00',
      pauseHours: 2,
      workedHours: 8,
      status: 'valid',
    ),
  ];
}