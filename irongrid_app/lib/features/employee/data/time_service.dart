import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'models/time_models.dart';

class TimeService {
  final ApiClient _api = ApiClient();

  Future<SessionStateResponse> state() async {
    final res = await _api.get("/api/time/state", withAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return SessionStateResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception("state failed: ${res.statusCode} ${res.body}");
  }

  Future<TimeSummaryResponse> summary() async {
    final res = await _api.get("/api/time/summary", withAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return TimeSummaryResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception("summary failed: ${res.statusCode} ${res.body}");
  }

  Future<SessionStateResponse> start({required String project}) async {
    final res = await _api.post(
      "/api/time/start",
      withAuth: true,
      body: {"project": project},
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return SessionStateResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception("start failed: ${res.statusCode} ${res.body}");
  }

  Future<SessionStateResponse> startBreak() async {
    final res = await _api.post("/api/time/break/start", withAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return SessionStateResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception("startBreak failed: ${res.statusCode} ${res.body}");
  }

  Future<SessionStateResponse> resume() async {
    final res = await _api.post("/api/time/break/resume", withAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return SessionStateResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception("resume failed: ${res.statusCode} ${res.body}");
  }

  Future<SessionStateResponse> end() async {
    final res = await _api.post("/api/time/end", withAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return SessionStateResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception("end failed: ${res.statusCode} ${res.body}");
  }
}