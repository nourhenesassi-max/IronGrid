class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String type;
  final bool read;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      read: json['read'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}