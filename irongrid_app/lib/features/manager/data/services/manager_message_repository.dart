import '../models/manager_conversation_model.dart';
import '../models/manager_message_model.dart';
import '../models/message_contact_model.dart';
import 'manager_message_api_service.dart';

class ManagerMessageRepository {
  final ManagerMessageApiService _api = ManagerMessageApiService();

  Future<List<MessageContactModel>> getMessageableUsers() async {
    final contacts = await _api.getMessageableUsers();

    return contacts.map((item) {
      String? avatarUrl;

      if (item.avatarUrl != null) {
        final value = item.avatarUrl!.trim();
        if (value.isNotEmpty && value.toLowerCase() != 'null') {
          avatarUrl = value;
        }
      }

      return MessageContactModel(
        id: item.id,
        name: item.name,
        role: item.role,
        email: item.email,
        avatarUrl: avatarUrl,
      );
    }).toList();
  }

  Future<List<ManagerConversationModel>> getConversations() {
    return _api.getConversations();
  }

  Future<ManagerConversationModel> getConversation(int conversationId) {
    return _api.getConversation(conversationId);
  }

  Future<ManagerConversationModel> startConversation(int receiverId) {
    return _api.startConversation(receiverId);
  }

  Future<ManagerMessageModel> sendMessage({
    required int conversationId,
    required String content,
  }) {
    return _api.sendMessage(
      conversationId: conversationId,
      content: content,
    );
  }

  Future<void> deleteConversation(int conversationId) {
    return _api.deleteConversation(conversationId);
  }

  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  }) {
    return _api.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
}