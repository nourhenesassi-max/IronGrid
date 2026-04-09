import '../../../../core/network/api_client.dart';
import '../models/manager_surveillance_model.dart';

class ManagerSurveillanceApiService {
  ManagerSurveillanceApiService({
    ApiClient? client,
  }) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String dvrsPath = '/api/manager/surveillance/dvrs';
  static const String camerasPath = '/api/manager/surveillance/cameras';

  Future<List<ManagerDvr>> getDvrs() async {
    final response = await _client.get(dvrsPath, withAuth: true);
    return _extractList(response)
        .map((item) => ManagerDvr.fromJson(item))
        .toList();
  }

  Future<ManagerDvr> createDvr(ManagerDvr dvr) async {
    final response = await _client.post(
      dvrsPath,
      withAuth: true,
      body: _toRequestBody(dvr),
    );
    return ManagerDvr.fromJson(
      _extractObject(response, fallback: _toRequestBody(dvr)),
    );
  }

  Future<ManagerDvr> updateDvr(ManagerDvr dvr) async {
    final response = await _client.put(
      '$dvrsPath/${dvr.id}',
      withAuth: true,
      body: _toRequestBody(dvr),
    );
    return ManagerDvr.fromJson(
      _extractObject(response, fallback: _toRequestBody(dvr)),
    );
  }

  Future<void> deleteDvr(String id) async {
    await _client.delete('$dvrsPath/$id', withAuth: true);
  }

  Future<ManagerDvr> updateCameraStatus(String cameraId, bool isOnline) async {
    final response = await _client.patch(
      '$camerasPath/$cameraId/status',
      withAuth: true,
      body: <String, dynamic>{
        'isOnline': isOnline,
      },
    );

    return ManagerDvr.fromJson(
      _extractObject(
        response,
        fallback: const <String, dynamic>{},
      ),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is List<dynamic>) {
      return response.whereType<Map<String, dynamic>>().toList();
    }

    if (response is Map<String, dynamic>) {
      final candidates = <dynamic>[
        response['items'],
        response['data'],
        response['content'],
        response['results'],
        response['dvrs'],
      ];

      for (final candidate in candidates) {
        if (candidate is List<dynamic>) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractObject(
    dynamic response, {
    required Map<String, dynamic> fallback,
  }) {
    if (response is Map<String, dynamic>) {
      for (final key in <String>['data', 'item', 'dvr']) {
        final nested = response[key];
        if (nested is Map<String, dynamic>) {
          return nested;
        }
      }
      return response;
    }
    return fallback;
  }

  Map<String, dynamic> _toRequestBody(ManagerDvr dvr) {
    return <String, dynamic>{
      'name': dvr.name,
      'site': dvr.site,
      'ipAddress': dvr.ipAddress,
      'port': dvr.port,
      'status': dvr.status,
      'protocol': dvr.protocol,
      'streamProfile': dvr.streamProfile,
      'notes': dvr.notes,
      'cameras': dvr.cameras.map(_toCameraRequestBody).toList(),
    };
  }

  Map<String, dynamic> _toCameraRequestBody(ManagerCameraFeed camera) {
    return <String, dynamic>{
      'id': camera.id,
      'name': camera.name,
      'zone': camera.zone,
      'channel': camera.channel,
      'isOnline': camera.isOnline,
      'recordingEnabled': camera.recordingEnabled,
      'motionEnabled': camera.motionEnabled,
      'resolution': camera.resolution,
      'bitrateKbps': camera.bitrateKbps,
      'latencyMs': camera.latencyMs,
      'streamUrl': camera.streamUrl,
      'archiveUrl': camera.archiveUrl,
      'previewImageUrl': camera.previewImageUrl,
      'streamType': camera.streamType,
      'lastHeartbeatAt': camera.lastHeartbeatAt.toIso8601String(),
    };
  }
}
