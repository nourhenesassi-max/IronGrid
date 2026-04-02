class SurveillanceCamera {
  final String id;
  final String dvrId;
  final String dvrName;
  final String name;
  final String zone;
  final int channel;
  final String status;
  final bool recordingEnabled;
  final String resolution;
  final int latencyMs;
  final int bitrateKbps;
  final String streamUrl;
  final String archiveUrl;
  final DateTime lastHeartbeatAt;

  const SurveillanceCamera({
    required this.id,
    required this.dvrId,
    required this.dvrName,
    required this.name,
    required this.zone,
    required this.channel,
    required this.status,
    required this.recordingEnabled,
    required this.resolution,
    required this.latencyMs,
    required this.bitrateKbps,
    required this.streamUrl,
    required this.archiveUrl,
    required this.lastHeartbeatAt,
  });

  factory SurveillanceCamera.fromJson(Map<String, dynamic> json) {
    final isOnline = _asBool(json['isOnline']);
    return SurveillanceCamera(
      id: _asString(json['id']),
      dvrId: _asString(json['dvrId']),
      dvrName: _asString(json['dvrName']),
      name: _asString(json['name']),
      zone: _asString(json['zone']),
      channel: _asInt(json['channel']),
      status: isOnline ? 'online' : 'offline',
      recordingEnabled: _asBool(json['recordingEnabled']),
      resolution: _asString(json['resolution'], fallback: '1920x1080'),
      latencyMs: _asInt(json['latencyMs']),
      bitrateKbps: _asInt(json['bitrateKbps']),
      streamUrl: _asString(json['streamUrl']),
      archiveUrl: _asString(json['archiveUrl']),
      lastHeartbeatAt: _asDateTime(json['lastHeartbeatAt']),
    );
  }

  bool get isOnline => status == 'online' || status == 'active';

  bool get hasLiveStream => streamUrl.trim().isNotEmpty;

  bool get hasArchive => archiveUrl.trim().isNotEmpty;

  String get statusLabel => isOnline ? 'En ligne' : 'Hors ligne';

  String get recordingLabel => recordingEnabled ? 'Rec actif' : 'Rec coupe';
}

class SurveillanceDvr {
  final String id;
  final String name;
  final String site;
  final String networkAddress;
  final String protocol;
  final String status;
  final List<SurveillanceCamera> cameras;

  const SurveillanceDvr({
    required this.id,
    required this.name,
    required this.site,
    required this.networkAddress,
    required this.protocol,
    required this.status,
    required this.cameras,
  });

  factory SurveillanceDvr.fromJson(Map<String, dynamic> json) {
    final ip = _asString(json['ipAddress']);
    final port = _asInt(json['port']);
    final cameras = _asList(json['cameras'])
        .map((item) => SurveillanceCamera.fromJson(_asMap(item)))
        .toList();

    return SurveillanceDvr(
      id: _asString(json['id']),
      name: _asString(json['name']),
      site: _asString(json['site']),
      networkAddress: ip.isEmpty ? '' : '$ip:$port',
      protocol: _asString(json['protocol']),
      status: _asString(json['status'], fallback: 'offline'),
      cameras: cameras,
    );
  }

  int get onlineCameras => cameras.where((camera) => camera.isOnline).length;

  int get recordingCameras =>
      cameras.where((camera) => camera.recordingEnabled).length;

  String get statusLabel {
    switch (status) {
      case 'online':
        return 'Operationnel';
      case 'degraded':
        return 'Degrade';
      case 'offline':
        return 'Hors ligne';
      default:
        return 'Inconnu';
    }
  }
}

class SurveillanceRecording {
  final String id;
  final String cameraId;
  final String cameraName;
  final String dvrName;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final String archiveUrl;
  final String trigger;
  final String sizeLabel;

  const SurveillanceRecording({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.dvrName,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.archiveUrl,
    required this.trigger,
    required this.sizeLabel,
  });

  factory SurveillanceRecording.fromJson(Map<String, dynamic> json) {
    return SurveillanceRecording(
      id: _asString(json['id']),
      cameraId: _asString(json['cameraId']),
      cameraName: _asString(json['cameraName']),
      dvrName: _asString(json['dvrName']),
      title: _asString(json['title']),
      startedAt: _asDateTime(json['startedAt']),
      endedAt: _asDateTime(json['endedAt']),
      archiveUrl: _asString(json['archiveUrl']),
      trigger: _asString(json['trigger']),
      sizeLabel: _asString(json['sizeLabel']),
    );
  }

  Duration get duration => endedAt.difference(startedAt);

  String get durationLabel {
    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')}';
    }
    return '$minutes min';
  }
}

class SurveillanceDashboard {
  final List<SurveillanceDvr> dvrs;
  final List<SurveillanceCamera> cameras;
  final List<SurveillanceRecording> recordings;
  final bool usingDemoData;
  final String sourceMessage;

  const SurveillanceDashboard({
    required this.dvrs,
    required this.cameras,
    required this.recordings,
    required this.usingDemoData,
    required this.sourceMessage,
  });

  factory SurveillanceDashboard.fromJson(Map<String, dynamic> json) {
    return SurveillanceDashboard(
      dvrs: _asList(json['dvrs'])
          .map((item) => SurveillanceDvr.fromJson(_asMap(item)))
          .toList(),
      cameras: _asList(json['cameras'])
          .map((item) => SurveillanceCamera.fromJson(_asMap(item)))
          .toList(),
      recordings: _asList(json['recordings'])
          .map((item) => SurveillanceRecording.fromJson(_asMap(item)))
          .toList(),
      usingDemoData: _asBool(json['usingDemoData']),
      sourceMessage: _asString(
        json['sourceMessage'],
        fallback: 'Supervision connectee au backend IronGrid.',
      ),
    );
  }

  int get onlineCameras => cameras.where((camera) => camera.isOnline).length;

  int get recordingCameras =>
      cameras.where((camera) => camera.recordingEnabled).length;
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  return value.toString();
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'online') {
    return true;
  }
  if (text == 'false' || text == '0' || text == 'offline') {
    return false;
  }
  return fallback;
}

DateTime _asDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }
  final text = value?.toString();
  return DateTime.tryParse(text ?? '') ?? DateTime.now();
}

List<dynamic> _asList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const <dynamic>[];
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return const <String, dynamic>{};
}
