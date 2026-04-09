class EmployeeModel {
  final int id;
  final String name;
  final String email;
  final String teamLabel;
  final String projectLabel;
  final String role;
  final String? avatarUrl; // ✅ added (optional, safe)

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.teamLabel,
    required this.projectLabel,
    required this.role,
    this.avatarUrl, // ✅ added
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final email = (json['email'] ?? '').toString();
    final rawAvatar = _extractAvatarValue(json);

    final fullName = ('$firstName $lastName').trim();
    final avatarValue = rawAvatar?.toString().trim();

    return EmployeeModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: fullName.isNotEmpty
          ? fullName
          : ((json['name'] ?? '').toString().isNotEmpty
              ? (json['name'] ?? '').toString()
              : email),
      email: email,
      teamLabel: (json['teamLabel'] ?? '').toString(),
      projectLabel: (json['projectLabel'] ?? '').toString(),
      role: (json['role'] ?? 'EMPLOYE').toString(),
      avatarUrl: (avatarValue != null &&
              avatarValue.isNotEmpty &&
              avatarValue.toLowerCase() != 'null')
          ? avatarValue
          : null,
    );
  }

  static dynamic _extractAvatarValue(Map<String, dynamic> json) {
    final direct = json['avatarUrl'] ??
        json['profilePhoto'] ??
        json['photoUrl'] ??
        json['photo'] ??
        json['imageUrl'] ??
        json['image'] ??
        json['avatar'];

    if (direct != null) {
      return direct;
    }

    for (final key in const ['user', 'employee', 'member', 'profile']) {
      final nested = json[key];
      if (nested is Map<String, dynamic>) {
        final nestedValue = _extractAvatarValue(nested);
        if (nestedValue != null) {
          return nestedValue;
        }
      }
    }

    return null;
  }
}
