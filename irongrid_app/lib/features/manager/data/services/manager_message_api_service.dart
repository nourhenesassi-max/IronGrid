import '../../../../core/network/api_client.dart';
import '../models/manager_conversation_model.dart';
import '../models/manager_message_model.dart';
import '../models/message_contact_model.dart';

class ManagerMessageApiService {
  final ApiClient _client = ApiClient();

  Future<List<MessageContactModel>> getMessageableUsers() async {
    final data = await _client.get(
      '/api/users/messageable',
      withAuth: true,
    ) as List<dynamic>;

    final users = data.map((e) {
      final json = Map<String, dynamic>.from(e as Map<String, dynamic>);

      final avatar = json['avatarUrl'] ??
          json['senderAvatarUrl'] ??
          json['profilePhoto'] ??
          json['photo'] ??
          json['image'] ??
          json['avatar'];

      if (avatar != null) {
        final value = avatar.toString().trim();
        if (value.isNotEmpty && value.toLowerCase() != 'null') {
          json['avatarUrl'] = value;
        }
      }

      return MessageContactModel.fromJson(json);
    }).toList();

    const hiddenUserIds = [5];

    return users.where((user) => !hiddenUserIds.contains(user.id)).toList();
  }

  Future<List<ManagerConversationModel>> getConversations() async {
    final data = await _client.get(
      '/api/messages/conversations',
      withAuth: true,
    ) as List<dynamic>;

    return data
        .map(
          (e) => ManagerConversationModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<ManagerConversationModel> getConversation(int conversationId) async {
    final data = await _client.get(
      '/api/messages/conversations/$conversationId',
      withAuth: true,
    ) as Map<String, dynamic>;

    return ManagerConversationModel.fromJson(data);
  }

  Future<ManagerConversationModel> startConversation(int receiverId) async {
    final data = await _client.post(
      '/api/messages/conversations',
      withAuth: true,
      body: {
        'receiverId': receiverId,
      },
    ) as Map<String, dynamic>;

    return ManagerConversationModel.fromJson(data);
  }

  Future<ManagerMessageModel> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final data = await _client.post(
      '/api/messages/conversations/$conversationId/messages',
      withAuth: true,
      body: {
        'content': content,
      },
    ) as Map<String, dynamic>;

    return ManagerMessageModel.fromJson(data);
  }

  Future<void> deleteConversation(int conversationId) async {
    await _client.delete(
      '/api/messages/conversations/$conversationId',
      withAuth: true,
    );
  }

  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  }) async {
    await _client.delete(
      '/api/messages/conversations/$conversationId/messages/$messageId',
      withAuth: true,
    );
  }
}