import '../../data/models/employee_models.dart';

class EmployeeChatArgs {
  final EmployeeConversation? conversation;
  final MessageableUser? selectedUser;

  const EmployeeChatArgs({
    this.conversation,
    this.selectedUser,
  });

  bool get isNewChat => conversation == null && selectedUser != null;
}