import '../../../core/network/api_client.dart';
import 'models/leave_models.dart';

class LeaveService {
  final ApiClient _api = ApiClient();

  Future<LeaveStatsResponse> getStats() async {
    final data = await _api.get(
      "/api/leave/stats",
      withAuth: true,
    ) as Map<String, dynamic>;

    return LeaveStatsResponse.fromJson(data);
  }

  Future<List<LeaveResponse>> getMine() async {
    final data = await _api.get(
      "/api/leave/mine",
      withAuth: true,
    ) as List<dynamic>;

    return data
        .map((e) => LeaveResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LeaveResponse> createLeave({
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    final data = await _api.post(
      "/api/leave",
      withAuth: true,
      body: {
        "type": type,
        "startDate": startDate,
        "endDate": endDate,
        "reason":
            (reason != null && reason.trim().isNotEmpty) ? reason.trim() : null,
      },
    ) as Map<String, dynamic>;

    return LeaveResponse.fromJson(data);
  }

  Future<LeaveResponse> cancelLeave(int id) async {
    final data = await _api.post(
      "/api/leave/$id/cancel",
      withAuth: true,
    ) as Map<String, dynamic>;

    return LeaveResponse.fromJson(data);
  }
}