class EmployeeConversationModel {
  final Map<String, dynamic>? lastMessage;
  final int unreadCount;

  // ✅ NEW (optional → no break)
  final String? avatarUrl;
  final String? contactName;
  final String? contactRole;
  final bool isGroup;
  final String? groupName;

  EmployeeConversationModel({
    this.lastMessage,
    required this.unreadCount,

    // ✅ NEW (optional)
    this.avatarUrl,
    this.contactName,
    this.contactRole,
    this.isGroup = false,
    this.groupName,
  });

  factory EmployeeConversationModel.fromJson(Map<String, dynamic> json) {
    final dynamic unread = json['unreadCount'];

    return EmployeeConversationModel(
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? json['lastMessage'] as Map<String, dynamic>
          : null,

      unreadCount:
          unread is int ? unread : int.tryParse(unread?.toString() ?? '0') ?? 0,

      // ✅ SAFE parsing (no crash if missing)
      avatarUrl: json['avatarUrl']?.toString(),
      contactName: json['contactName']?.toString(),
      contactRole: json['contactRole']?.toString(),
      isGroup: json['group'] == true,
      groupName: json['groupName']?.toString(),
    );
  }
}