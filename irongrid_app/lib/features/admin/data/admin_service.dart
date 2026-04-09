import '../../../core/network/api_client.dart';

class PendingUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? teamLabel;
  final String? projectLabel;
  final String status;

  PendingUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.teamLabel,
    required this.projectLabel,
    required this.status,
  });

  factory PendingUser.fromJson(Map<String, dynamic> json) {
    return PendingUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      teamLabel: json['teamLabel']?.toString(),
      projectLabel: json['projectLabel']?.toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class ApprovedUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? teamLabel;
  final String? projectLabel;
  final String status;
  final String? role;

  ApprovedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.teamLabel,
    required this.projectLabel,
    required this.status,
    required this.role,
  });

  factory ApprovedUser.fromJson(Map<String, dynamic> json) {
    return ApprovedUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      teamLabel: json['teamLabel']?.toString(),
      projectLabel: json['projectLabel']?.toString(),
      status: (json['status'] ?? '').toString(),
      role: json['role']?.toString(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class RejectedUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? teamLabel;
  final String? projectLabel;
  final String status;

  RejectedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.teamLabel,
    required this.projectLabel,
    required this.status,
  });

  factory RejectedUser.fromJson(Map<String, dynamic> json) {
    return RejectedUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      teamLabel: json['teamLabel']?.toString(),
      projectLabel: json['projectLabel']?.toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class AdminStats {
  final int pendingRequests;
  final int approvedUsers;
  final int rejectedUsers;

  AdminStats({
    required this.pendingRequests,
    required this.approvedUsers,
    required this.rejectedUsers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      pendingRequests: json['pendingRequests'] is int
          ? json['pendingRequests']
          : int.tryParse(json['pendingRequests'].toString()) ?? 0,
      approvedUsers: json['approvedUsers'] is int
          ? json['approvedUsers']
          : int.tryParse(json['approvedUsers'].toString()) ?? 0,
      rejectedUsers: json['rejectedUsers'] is int
          ? json['rejectedUsers']
          : int.tryParse(json['rejectedUsers'].toString()) ?? 0,
    );
  }
}

class AdminService {
  final ApiClient _api = ApiClient();

  Future<AdminStats> getDashboardStats() async {
    final data =
        await _api.get('/api/admin/dashboard-stats') as Map<String, dynamic>;
    return AdminStats.fromJson(data);
  }

  Future<List<PendingUser>> getPendingUsers() async {
    final data = await _api.get('/api/admin/pending-users') as List<dynamic>;
    return data
        .map((e) => PendingUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ApprovedUser>> getApprovedUsers() async {
    final data = await _api.get('/api/admin/approved-users') as List<dynamic>;
    return data
        .map((e) => ApprovedUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RejectedUser>> getRejectedUsers() async {
    final data = await _api.get('/api/admin/rejected-users') as List<dynamic>;
    return data
        .map((e) => RejectedUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> approveUser({
    required int userId,
    required String role,
  }) async {
    final data = await _api.post(
      '/api/admin/users/$userId/approve',
      body: {'role': role},
    ) as Map<String, dynamic>;

    return (data['message'] ?? 'Utilisateur approuvé').toString();
  }

  Future<String> rejectUser({
    required int userId,
  }) async {
    final data = await _api.post(
      '/api/admin/users/$userId/reject',
      body: <String, dynamic>{},
    ) as Map<String, dynamic>;

    return (data['message'] ?? 'Utilisateur rejeté').toString();
  }

  Future<String> deleteUser(int userId) async {
    final data = await _api.delete('/api/admin/users/$userId');

    if (data == null) {
      return 'Utilisateur supprimé avec succès';
    }

    if (data is Map<String, dynamic>) {
      return (data['message'] ?? 'Utilisateur supprimé avec succès').toString();
    }

    return data.toString();
  }

  Future<String> deleteAllRejectedUsers() async {
    final data = await _api.delete('/api/admin/rejected-users');

    if (data == null) {
      return 'Liste supprimée';
    }

    if (data is Map<String, dynamic>) {
      return (data['message'] ?? 'Liste supprimée').toString();
    }

    return data.toString();
  }
}