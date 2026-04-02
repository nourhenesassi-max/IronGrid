class ManagerCameraFeed {
  final String id;
  final String name;
  final String zone;
  final int channel;
  final bool isOnline;
  final bool recordingEnabled;
  final bool motionEnabled;
  final String resolution;
  final int bitrateKbps;
  final int latencyMs;
  final String streamUrl;
  final String archiveUrl;
  final String previewImageUrl;
  final String streamType;
  final DateTime lastHeartbeatAt;

  const ManagerCameraFeed({
    required this.id,
    required this.name,
    required this.zone,
    required this.channel,
    required this.isOnline,
    required this.recordingEnabled,
    required this.motionEnabled,
    required this.resolution,
    required this.bitrateKbps,
    required this.latencyMs,
    required this.streamUrl,
    required this.archiveUrl,
    required this.previewImageUrl,
    required this.streamType,
    required this.lastHeartbeatAt,
  });

  String get statusLabel => isOnline ? 'En ligne' : 'Hors ligne';

  String get latencyLabel => isOnline ? '$latencyMs ms' : 'Indisponible';

  bool get hasLiveStream => streamUrl.trim().isNotEmpty;

  bool get hasArchive => archiveUrl.trim().isNotEmpty;

  bool get hasPreview => previewImageUrl.trim().isNotEmpty;

  ManagerCameraFeed copyWith({
    String? id,
    String? name,
    String? zone,
    int? channel,
    bool? isOnline,
    bool? recordingEnabled,
    bool? motionEnabled,
    String? resolution,
    int? bitrateKbps,
    int? latencyMs,
    String? streamUrl,
    String? archiveUrl,
    String? previewImageUrl,
    String? streamType,
    DateTime? lastHeartbeatAt,
  }) {
    return ManagerCameraFeed(
      id: id ?? this.id,
      name: name ?? this.name,
      zone: zone ?? this.zone,
      channel: channel ?? this.channel,
      isOnline: isOnline ?? this.isOnline,
      recordingEnabled: recordingEnabled ?? this.recordingEnabled,
      motionEnabled: motionEnabled ?? this.motionEnabled,
      resolution: resolution ?? this.resolution,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
      latencyMs: latencyMs ?? this.latencyMs,
      streamUrl: streamUrl ?? this.streamUrl,
      archiveUrl: archiveUrl ?? this.archiveUrl,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      streamType: streamType ?? this.streamType,
      lastHeartbeatAt: lastHeartbeatAt ?? this.lastHeartbeatAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'zone': zone,
      'channel': channel,
      'isOnline': isOnline,
      'recordingEnabled': recordingEnabled,
      'motionEnabled': motionEnabled,
      'resolution': resolution,
      'bitrateKbps': bitrateKbps,
      'latencyMs': latencyMs,
      'streamUrl': streamUrl,
      'archiveUrl': archiveUrl,
      'previewImageUrl': previewImageUrl,
      'streamType': streamType,
      'lastHeartbeatAt': lastHeartbeatAt.toIso8601String(),
    };
  }

  factory ManagerCameraFeed.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['state'] ?? json['health'])
        .toString()
        .toLowerCase();

    return ManagerCameraFeed(
      id: (json['id'] ?? json['cameraId'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['label'] ?? json['title'] ?? '').toString(),
      zone: (json['zone'] ?? json['location'] ?? json['area'] ?? '').toString(),
      channel:
          _toInt(json['channel'] ?? json['channelNumber'] ?? json['index'], 1),
      isOnline: _toBool(
        json['isOnline'] ?? json['online'],
        fallback: rawStatus == 'online' || rawStatus == 'active',
      ),
      recordingEnabled: _toBool(
        json['recordingEnabled'] ?? json['recording'] ?? json['isRecording'],
      ),
      motionEnabled: _toBool(
        json['motionEnabled'] ?? json['motion'] ?? json['motionDetection'],
      ),
      resolution: (json['resolution'] ??
              json['quality'] ??
              json['videoQuality'] ??
              '1920x1080')
          .toString(),
      bitrateKbps: _toInt(json['bitrateKbps'] ?? json['bitrate'], 0),
      latencyMs: _toInt(json['latencyMs'] ?? json['latency'], 0),
      streamUrl: (json['streamUrl'] ??
              json['stream'] ??
              json['liveUrl'] ??
              json['liveStreamUrl'] ??
              '')
          .toString(),
      archiveUrl: (json['archiveUrl'] ??
              json['recordingUrl'] ??
              json['playbackUrl'] ??
              json['archiveStreamUrl'] ??
              '')
          .toString(),
      previewImageUrl: (json['previewImageUrl'] ??
              json['snapshotUrl'] ??
              json['thumbnailUrl'] ??
              json['posterUrl'] ??
              '')
          .toString(),
      streamType: (json['streamType'] ??
              json['protocol'] ??
              json['sourceType'] ??
              'rtsp')
          .toString()
          .toLowerCase(),
      lastHeartbeatAt: DateTime.tryParse(
            (json['lastHeartbeatAt'] ??
                    json['lastSeenAt'] ??
                    json['updatedAt'] ??
                    '')
                .toString(),
          ) ??
          DateTime.now(),
    );
  }
}

class ManagerDvr {
  final String id;
  final String name;
  final String site;
  final String ipAddress;
  final int port;
  final String status;
  final String protocol;
  final String streamProfile;
  final String notes;
  final DateTime updatedAt;
  final List<ManagerCameraFeed> cameras;

  const ManagerDvr({
    required this.id,
    required this.name,
    required this.site,
    required this.ipAddress,
    required this.port,
    required this.status,
    required this.protocol,
    required this.streamProfile,
    required this.notes,
    required this.updatedAt,
    required this.cameras,
  });

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

  String get networkAddress => '$ipAddress:$port';

  int get totalCameras => cameras.length;

  int get onlineCameras => cameras.where((camera) => camera.isOnline).length;

  int get offlineCameras => totalCameras - onlineCameras;

  int get recordingCameras =>
      cameras.where((camera) => camera.recordingEnabled).length;

  double get availabilityRatio =>
      totalCameras == 0 ? 0 : onlineCameras / totalCameras;

  ManagerDvr copyWith({
    String? id,
    String? name,
    String? site,
    String? ipAddress,
    int? port,
    String? status,
    String? protocol,
    String? streamProfile,
    String? notes,
    DateTime? updatedAt,
    List<ManagerCameraFeed>? cameras,
  }) {
    return ManagerDvr(
      id: id ?? this.id,
      name: name ?? this.name,
      site: site ?? this.site,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      status: status ?? this.status,
      protocol: protocol ?? this.protocol,
      streamProfile: streamProfile ?? this.streamProfile,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      cameras: cameras ?? this.cameras,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'site': site,
      'ipAddress': ipAddress,
      'port': port,
      'status': status,
      'protocol': protocol,
      'streamProfile': streamProfile,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
      'cameras': cameras.map((camera) => camera.toJson()).toList(),
    };
  }

  factory ManagerDvr.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['health'] ?? json['state'])
        .toString()
        .toLowerCase();
    final rawCameras = json['cameras'] ??
        json['cameraFeeds'] ??
        json['channels'] ??
        <dynamic>[];

    return ManagerDvr(
      id: (json['id'] ?? json['dvrId'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['label'] ?? json['title'] ?? '').toString(),
      site: (json['site'] ?? json['location'] ?? json['zone'] ?? '').toString(),
      ipAddress: (json['ipAddress'] ?? json['host'] ?? json['address'] ?? '')
          .toString(),
      port: _toInt(json['port'], 554),
      status: rawStatus.isEmpty ? 'offline' : rawStatus,
      protocol: _normalizeProtocol(
        (json['protocol'] ?? json['transport'] ?? 'RTSP').toString(),
      ),
      streamProfile: (json['streamProfile'] ??
              json['profile'] ??
              json['quality'] ??
              'Full HD')
          .toString(),
      notes: (json['notes'] ?? json['description'] ?? '').toString(),
      updatedAt: DateTime.tryParse(
            (json['updatedAt'] ?? json['lastUpdatedAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      cameras: (rawCameras as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(ManagerCameraFeed.fromJson)
          .toList(),
    );
  }
}

int _toInt(dynamic value, int fallback) {
  if (value == null) {
    return fallback;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString()) ?? fallback;
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value == null) {
    return fallback;
  }
  if (value is bool) {
    return value;
  }
  final normalized = value.toString().trim().toLowerCase();
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'online' ||
      normalized == 'active';
}

String _normalizeProtocol(String protocol) {
  switch (protocol.trim().toUpperCase()) {
    case 'RTSP':
      return 'RTSP';
    case 'HLS':
      return 'HLS';
    case 'HTTP':
      return 'HTTP';
    case 'HTTPS':
      return 'HTTPS';
    case 'ONVIF':
      return 'ONVIF';
    default:
      return 'RTSP';
  }
}