import 'manager_message_model.dart';

class ManagerConversationModel {
  final int id;
  final int? contactId;
  final String contactName;
  final String contactRole;
  final String? avatarUrl;
  final ManagerMessageModel? lastMessage;
  final List<ManagerMessageModel> messages;
  final bool group;
  final String? groupName;
  final int? memberCount;
  final bool hasUnread;

  ManagerConversationModel({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.contactRole,
    required this.avatarUrl,
    required this.lastMessage,
    required this.messages,
    required this.group,
    required this.groupName,
    required this.memberCount,
    required this.hasUnread,
  });

  factory ManagerConversationModel.fromJson(Map<String, dynamic> json) {
    return ManagerConversationModel(
      id: _toInt(json['id']),
      contactId: json['contactId'] == null ? null : _toInt(json['contactId']),
      contactName: (json['contactName'] ?? '').toString(),
      contactRole: (json['contactRole'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      lastMessage: json['lastMessage'] == null
          ? null
          : ManagerMessageModel.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((e) => ManagerMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      group: json['group'] == true,
      groupName: json['groupName']?.toString(),
      memberCount:
          json['memberCount'] == null ? null : _toInt(json['memberCount']),
      hasUnread:
          json.containsKey('hasUnread') ? json['hasUnread'] == true : false,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}