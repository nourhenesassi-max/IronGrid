import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../employee/data/models/employee_models.dart';

class EmployeeMessageApi {
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  EmployeeMessageApi({
    required this.baseUrl,
    required this.tokenProvider,
  });

  Future<Map<String, String>> _headers() async {
    final token = await tokenProvider();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<EmployeeConversation>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages/conversations'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Erreur chargement conversations'),
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((e) => EmployeeConversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadMessagesCount() async {
    final conversations = await getConversations();

    int total = 0;
    for (final conversation in conversations) {
      total += _extractUnreadCount(conversation);
    }

    return total;
  }

  Stream<int> watchUnreadMessagesCount({
    Duration interval = const Duration(seconds: 5),
  }) async* {
    while (true) {
      try {
        final count = await getUnreadMessagesCount();
        yield count;
      } catch (_) {
        yield 0;
      }
      await Future.delayed(interval);
    }
  }

  int _extractUnreadCount(EmployeeConversation conversation) {
    try {
      final dynamic c = conversation;

      final dynamic unreadCount = c.unreadCount;
      if (unreadCount is int) return unreadCount;

      final dynamic unreadMessages = c.unreadMessages;
      if (unreadMessages is int) return unreadMessages;

      final dynamic unread = c.unread;
      if (unread is int) return unread;
      if (unread is bool) return unread ? 1 : 0;
    } catch (_) {}

    return 0;
  }

  Future<EmployeeConversation> getConversation(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages/conversations/$conversationId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Erreur chargement conversation'),
      );
    }

    return EmployeeConversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<EmployeeConversation> startConversation(String receiverId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages/conversations'),
      headers: await _headers(),
      body: jsonEncode({
        'receiverId': int.parse(receiverId),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Erreur création conversation'),
      );
    }

    return EmployeeConversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<EmployeeConversation> createGroupConversation({
    required String groupName,
    required List<String> memberIds,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages/groups'),
      headers: await _headers(),
      body: jsonEncode({
        'groupName': groupName.trim(),
        'memberIds': memberIds.map(int.parse).toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Erreur création groupe'),
      );
    }

    return EmployeeConversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<EmployeeMessage> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages/conversations/$conversationId/messages'),
      headers: await _headers(),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Erreur envoi message'),
      );
    }

    return EmployeeMessage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/api/messages/conversations/$conversationId/messages/$messageId',
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Erreur suppression message'),
      );
    }
  }

  Future<List<MessageableUser>> getMessageableUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/messageable'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response.body, 'Erreur chargement utilisateurs'),
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((e) => MessageableUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _extractError(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['error'] != null) {
          return decoded['error'].toString();
        }
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}
