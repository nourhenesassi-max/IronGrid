import 'package:flutter/material.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/reset_password_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/admin/presentation/admin_screen.dart';
import 'features/admin/presentation/pending_users_screen.dart';
import 'features/admin/presentation/approved_users_screen.dart';
import 'features/admin/presentation/rejected_users_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';

// Employee
import 'features/employee/data/models/employee_profile.dart';
import 'features/employee/presentation/screens/employee_dashboard_screen.dart';
import 'features/employee/presentation/screens/employee_profile_screen.dart';
import 'features/employee/presentation/screens/employee_timesheet_screen.dart';
import 'features/employee/presentation/screens/employee_projects_screen.dart';
import 'features/employee/presentation/screens/employee_project_details_screen.dart';
import 'features/employee/presentation/screens/employee_notifications_screen.dart';
import 'features/employee/presentation/screens/employee_messages_screen.dart';
import 'features/employee/presentation/screens/employee_timesheet_history_screen.dart';
import 'features/employee/presentation/screens/employee_chat_detail_screen.dart';
import 'features/employee/presentation/screens/employee_leave_screen.dart';
import 'features/employee/presentation/screens/employee_new_leave_screen.dart';
import 'features/employee/presentation/screens/personal_info_screen.dart';

// Frais
import 'features/frais/presentation/screens/employe_scan_frais_screen.dart';
import 'features/frais/presentation/screens/employe_frais_list_screen.dart';

// Manager
import 'features/manager/presentation/screens/manager_dashboard_screen.dart';
import 'features/manager/presentation/screens/manager_alerts_screen.dart';
import 'features/manager/presentation/screens/manager_messages_screen.dart';
import 'features/manager/presentation/screens/manager_settings_screen.dart';
import 'features/manager/presentation/screens/manager_profile_screen.dart';
import 'features/manager/presentation/screens/manager_team_screen.dart';
import 'features/manager/presentation/screens/manager_employee_screen.dart';
import 'features/manager/presentation/screens/manager_assign_task_screen.dart';
import 'features/manager/presentation/screens/manager_statistics_screen.dart';
import 'features/manager/presentation/screens/manager_create_report_screen.dart';
import 'features/manager/presentation/screens/manager_alert_detail_screen.dart';
import 'features/manager/presentation/screens/manager_edit_profile_screen.dart';
import 'features/manager/presentation/screens/manager_projects_screen.dart';
import 'features/manager/presentation/screens/manager_workload_screen.dart';
import 'features/manager/presentation/screens/manager_send_notification_screen.dart';
import 'features/manager/presentation/screens/manager_chat_detail_screen.dart';
import 'features/manager/presentation/screens/manager_chat_start_screen.dart';
import 'features/manager/presentation/screens/manager_surveillance_screen.dart';

// RH
import 'features/rh/presentation/screens/rh_dashboard_screen.dart';

class IndustrialManagerApp extends StatelessWidget {
  const IndustrialManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IronGrid',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E293B),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      ),
      initialRoute: '/splash',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/admin': (_) => const AdminScreen(),
        '/admin/approved-users': (_) => const ApprovedUsersScreen(),
        '/admin/pending-users': (_) => const PendingUsersScreen(),
        '/admin/rejected-users': (_) => const RejectedUsersScreen(),
        '/employe': (_) => const EmployeeDashboardScreen(),
        '/employe-profile': (_) => const EmployeeProfileScreen(),
        '/employe-timesheet': (_) => const EmployeeTimesheetScreen(),
        '/employe-scan-frais': (_) => const EmployeScanFraisScreen(),
        '/employe-frais': (_) => const EmployeFraisListScreen(),
        '/employe-projects': (_) => const EmployeeProjectsScreen(),
        '/employe-project-details': (_) => const EmployeeProjectDetailsScreen(),
        '/employe-notifications': (_) => const EmployeeNotificationsScreen(),
        '/employe-messages': (_) => const EmployeeMessagesScreen(),
        '/employe-timesheet-history': (_) =>
            const EmployeeTimesheetHistoryScreen(),
        '/employe-chat-detail': (_) => const EmployeeChatDetailScreen(),
        '/employe-leaves': (_) => const EmployeeLeaveScreen(),
        '/employe-new-leave': (_) => const EmployeeNewLeaveScreen(),
        '/manager': (_) => const ManagerDashboardScreen(),
        '/manager/dashboard': (_) => const ManagerDashboardScreen(),
        '/manager/alerts': (_) => const ManagerAlertsScreen(),
        '/manager/messages': (_) => const ManagerMessagesScreen(),
        '/manager/settings': (_) => const ManagerSettingsScreen(),
        '/manager/profile': (_) => const ManagerProfileScreen(),
        '/manager/team': (_) => const ManagerTeamScreen(),
        '/manager/employee': (_) => const ManagerEmployeeScreen(),
        '/manager/assign_task': (_) => const ManagerAssignTaskScreen(),
        '/manager/statistics': (_) => const ManagerStatisticsScreen(),
        '/manager/create_report': (_) => const ManagerCreateReportScreen(),
        '/manager/alert_detail': (_) => const ManagerAlertDetailScreen(),
        '/manager/edit-profile': (_) => const ManagerEditProfileScreen(),
        '/manager/projects': (_) => const ManagerProjectsScreen(),
        '/manager/workload': (_) => const ManagerWorkloadScreen(),
        '/manager/send-notification': (_) =>
            const ManagerSendNotificationScreen(),
        '/manager/surveillance': (_) => const ManagerSurveillanceScreen(),
        '/manager/chat-start': (_) => const ManagerChatStartScreen(),
        '/manager/chat-detail': (_) => const ManagerChatDetailScreen(),
        '/rh': (_) => const RhDashboardScreen(),
        '/rh/dashboard': (_) => const RhDashboardScreen(),
        '/finance': (_) => const Scaffold(
              body: Center(child: Text('Dashboard Finance non implémenté')),
            ),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/manager/chat-start':
            return MaterialPageRoute(
              builder: (_) => const ManagerChatStartScreen(),
            );

          case '/manager/chat-detail':
            return MaterialPageRoute(
              builder: (_) => const ManagerChatDetailScreen(),
            );

          case '/employe-personal-info':
            final profile = settings.arguments as EmployeeProfile;
            return MaterialPageRoute(
              builder: (_) => PersonalInfoScreen(profile: profile),
            );
        }

        return null;
      },
    );
  }
}
