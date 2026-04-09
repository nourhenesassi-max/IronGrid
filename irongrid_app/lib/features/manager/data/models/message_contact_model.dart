class MessageContactModel {
  final int id;
  final String name;
  final String role;
  final String email;
  final String? avatarUrl; // ✅ added (optional, safe)

  MessageContactModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.avatarUrl,
  });

  factory MessageContactModel.fromJson(Map<String, dynamic> json) {
    return MessageContactModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}