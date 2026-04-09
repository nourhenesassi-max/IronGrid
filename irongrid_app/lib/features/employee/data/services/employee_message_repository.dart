import '../models/employee_conversation_model.dart';
import '../../../../core/network/api_client.dart';

class EmployeeMessageRepository {
  final ApiClient _client = ApiClient();

  Future<List<EmployeeConversationModel>> getConversations() async {
    final data = await _client.get(
      '/api/messages/conversations',
      withAuth: true,
    ) as List<dynamic>;

    return data.map((e) => EmployeeConversationModel.fromJson(e)).toList();
  }
}