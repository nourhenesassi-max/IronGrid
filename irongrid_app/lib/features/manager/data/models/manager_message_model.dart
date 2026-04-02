class ManagerMessageModel {
  final int id;
  final int senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String sentAt;
  final bool mine;
  final bool deleted;
  final String? senderAvatarUrl; // ✅ added

  ManagerMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.sentAt,
    required this.mine,
    required this.deleted,
    this.senderAvatarUrl, // ✅ added
  });

  factory ManagerMessageModel.fromJson(Map<String, dynamic> json) {
    return ManagerMessageModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      senderId: json['senderId'] is int
          ? json['senderId']
          : int.parse(json['senderId'].toString()),
      senderName: (json['senderName'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      sentAt: (json['sentAt'] ?? '').toString(),
      mine: json['mine'] == true,
      deleted: json['deleted'] == true,
      senderAvatarUrl: json['senderAvatarUrl']?.toString(), // ✅ added
    );
  }
}
