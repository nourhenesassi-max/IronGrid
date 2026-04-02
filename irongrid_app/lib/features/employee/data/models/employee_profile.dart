class EmployeeProfile {
  final String name;
  final String avatarUrl;
  final String? avatarPath;
  final String teamLabel;
  final String projectLabel;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String department;

  EmployeeProfile({
    required this.name,
    required this.avatarUrl,
    this.avatarPath,
    required this.teamLabel,
    required this.projectLabel,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.department,
  });

  factory EmployeeProfile.fromProfileJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final fullName = (json['name'] ?? '').toString().trim();

    final computedName =
        fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim();

    final rawAvatar = (json['avatarUrl'] ?? '').toString();

    final fallbackAvatar =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(computedName.isEmpty ? "User" : computedName)}';

    return EmployeeProfile(
      name: computedName,
      avatarUrl: rawAvatar.isNotEmpty ? rawAvatar : fallbackAvatar,
      avatarPath: null,
      teamLabel: (json['teamLabel'] ?? '').toString(),
      projectLabel: (json['projectLabel'] ?? '').toString(),
      firstName: firstName,
      lastName: lastName,
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
    );
  }

  EmployeeProfile copyWith({
    String? name,
    String? avatarUrl,
    String? avatarPath,
    String? teamLabel,
    String? projectLabel,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? department,
  }) {
    return EmployeeProfile(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarPath: avatarPath ?? this.avatarPath,
      teamLabel: teamLabel ?? this.teamLabel,
      projectLabel: projectLabel ?? this.projectLabel,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      department: department ?? this.department,
    );
  }
}