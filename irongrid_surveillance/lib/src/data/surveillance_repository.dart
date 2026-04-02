import '../models/surveillance_models.dart';
import '../network/surveillance_api_client.dart';

class SurveillanceRepository {
  SurveillanceRepository._();

  static final SurveillanceRepository instance = SurveillanceRepository._();

  final SurveillanceApiClient _apiClient = SurveillanceApiClient();

  Future<SurveillanceDashboard> loadDashboard() async {
    final payload = await _apiClient.get(
      '/api/manager/surveillance/dashboard?recordingsLimit=40',
    );

    return SurveillanceDashboard.fromJson(_requireMap(payload));
  }

  Future<SurveillanceCamera> loadCamera(String cameraId) async {
    final payload = await _apiClient.get(
      '/api/manager/surveillance/cameras/$cameraId',
    );

    return SurveillanceCamera.fromJson(_requireMap(payload));
  }

  Future<List<SurveillanceRecording>> loadCameraRecordings(
    String cameraId, {
    int limit = 24,
  }) async {
    final payload = await _apiClient.get(
      '/api/manager/surveillance/cameras/$cameraId/recordings?limit=$limit',
    );

    return _requireList(payload)
        .map(SurveillanceRecording.fromJson)
        .toList();
  }

  Map<String, dynamic> _requireMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    throw SurveillanceApiException(
      'Reponse backend invalide pour la supervision.',
    );
  }

  List<Map<String, dynamic>> _requireList(dynamic payload) {
    if (payload is List<dynamic>) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    throw SurveillanceApiException(
      'Liste backend invalide pour la supervision.',
    );
  }
}
