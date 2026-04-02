import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../models/manager_surveillance_model.dart';
import 'manager_surveillance_api_service.dart';

class ManagerSurveillanceStore {
  ManagerSurveillanceStore._();

  static final ManagerSurveillanceStore instance = ManagerSurveillanceStore._();

  static const String _storageKey = 'manager_surveillance_dvrs_v4';

  final ManagerSurveillanceApiService _api = ManagerSurveillanceApiService();

  final ValueNotifier<List<ManagerDvr>> dvrs =
      ValueNotifier<List<ManagerDvr>>(<ManagerDvr>[]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isUsingDemoData = ValueNotifier<bool>(false);
  final ValueNotifier<String?> syncMessage = ValueNotifier<String?>(null);

  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }

    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    final cached = _readFromPrefs(prefs);

    if (cached.isNotEmpty) {
      dvrs.value = cached;
      isUsingDemoData.value = true;
      syncMessage.value = 'Dernier etat synchronise charge.';
    }

    _loaded = true;
    isLoading.value = false;

    await refreshFromApi(
      showStatusMessage: cached.isEmpty,
      throwOnError: false,
    );
  }

  Future<void> refreshFromApi({
    bool showStatusMessage = true,
    bool throwOnError = false,
    bool manageSyncState = true,
  }) async {
    if (manageSyncState) {
      isSyncing.value = true;
    }

    try {
      final remoteDvrs = await _api.getDvrs();
      final sorted = [...remoteDvrs]..sort(_compareDvrs);
      dvrs.value = sorted;
      await _saveCurrent();
      isUsingDemoData.value = false;
      syncMessage.value = showStatusMessage
          ? 'Supervision synchronisee avec la base de donnees.'
          : null;
    } catch (error) {
      final hasCachedData = dvrs.value.isNotEmpty;
      isUsingDemoData.value = hasCachedData;
      syncMessage.value = showStatusMessage
          ? _readFailureMessage(hasCachedData: hasCachedData)
          : null;

      if (throwOnError) {
        rethrow;
      }
    } finally {
      if (manageSyncState) {
        isSyncing.value = false;
      }
    }
  }

  ManagerDvr? getById(String id) {
    for (final dvr in dvrs.value) {
      if (dvr.id == id) {
        return dvr;
      }
    }
    return null;
  }

  Future<void> addDvr(ManagerDvr dvr) async {
    await _runWriteOperation(
      () async {
        final created = await _api.createDvr(dvr);
        final updatedList = [...dvrs.value, created]..sort(_compareDvrs);
        dvrs.value = updatedList;
        await _saveCurrent();
      },
      successMessage: 'DVR enregistre dans la base de donnees.',
      fallbackMessage:
          'Impossible d enregistrer ce DVR dans la base de donnees.',
    );
  }

  Future<void> updateDvr(ManagerDvr dvr) async {
    await _runWriteOperation(
      () async {
        final updated = await _api.updateDvr(dvr);
        final updatedList = dvrs.value
            .map((item) => item.id == dvr.id ? updated : item)
            .toList()
          ..sort(_compareDvrs);
        dvrs.value = updatedList;
        await _saveCurrent();
      },
      successMessage: 'Modification enregistree dans la base de donnees.',
      fallbackMessage:
          'Impossible d enregistrer la modification dans la base de donnees.',
    );
  }

  Future<void> deleteDvr(String id) async {
    await _runWriteOperation(
      () async {
        await _api.deleteDvr(id);
        final updatedList = dvrs.value.where((item) => item.id != id).toList()
          ..sort(_compareDvrs);
        dvrs.value = updatedList;
        await _saveCurrent();
      },
      successMessage: 'DVR supprime de la base de donnees.',
      fallbackMessage:
          'Impossible de supprimer ce DVR de la base de donnees.',
    );
  }

  Future<void> updateCameraStatus({
    required String cameraId,
    required bool isOnline,
  }) async {
    await _runWriteOperation(
      () async {
        final updatedDvr = await _api.updateCameraStatus(cameraId, isOnline);
        final updatedList = dvrs.value
            .map((item) => item.id == updatedDvr.id ? updatedDvr : item)
            .toList()
          ..sort(_compareDvrs);
        dvrs.value = updatedList;
        await _saveCurrent();
      },
      successMessage: isOnline
          ? 'Camera remise en ligne dans la base de donnees.'
          : 'Camera passee hors ligne dans la base de donnees.',
      fallbackMessage: isOnline
          ? 'Impossible de remettre cette camera en ligne dans la base de donnees.'
          : 'Impossible de passer cette camera hors ligne dans la base de donnees.',
    );
  }

  Future<void> _runWriteOperation(
    Future<void> Function() operation, {
    required String successMessage,
    required String fallbackMessage,
  }) async {
    isSyncing.value = true;

    try {
      await operation();
      isUsingDemoData.value = false;
      syncMessage.value = successMessage;
    } catch (error) {
      syncMessage.value = _writeFailureMessage(error, fallbackMessage);
      rethrow;
    } finally {
      isSyncing.value = false;
    }
  }

  static ManagerDvr composeDvr({
    String? id,
    required String name,
    required String site,
    required String ipAddress,
    required int port,
    required String status,
    required String protocol,
    required String streamProfile,
    required int cameraCount,
    String notes = '',
    List<ManagerCameraFeed> existingCameras = const <ManagerCameraFeed>[],
  }) {
    final safeCount = cameraCount.clamp(1, 32).toInt();
    final resolution = _resolutionForProfile(streamProfile);
    final normalizedProtocol = _normalizeProtocol(protocol);

    final cameras = List<ManagerCameraFeed>.generate(safeCount, (index) {
      final existing =
          index < existingCameras.length ? existingCameras[index] : null;
      final livePath =
          _buildLiveUrl(ipAddress, port, index + 1, normalizedProtocol);
      final archivePath = _buildArchiveUrl(ipAddress, port, index + 1);
      final isOnline = _cameraOnlineForStatus(status, index);

      return ManagerCameraFeed(
        id: existing?.id ?? '${id ?? _slugify(name)}_cam_${index + 1}',
        name: existing?.name ?? _cameraName(index + 1),
        zone: existing?.zone ?? _cameraZone(site, index),
        channel: index + 1,
        isOnline: existing?.isOnline ?? isOnline,
        recordingEnabled: existing?.recordingEnabled ?? (status != 'offline'),
        motionEnabled:
            existing?.motionEnabled ?? (status != 'offline' && index.isEven),
        resolution: existing?.resolution ?? resolution,
        bitrateKbps:
            existing?.bitrateKbps ?? (isOnline ? 1400 + (index * 180) : 0),
        latencyMs: existing?.latencyMs ?? (isOnline ? 38 + (index * 9) : 0),
        streamUrl: existing?.streamUrl ?? livePath,
        archiveUrl: existing?.archiveUrl ?? archivePath,
        previewImageUrl: existing?.previewImageUrl ?? '',
        streamType: existing?.streamType ?? normalizedProtocol.toLowerCase(),
        lastHeartbeatAt: existing?.lastHeartbeatAt ??
            DateTime.now().subtract(
              Duration(
                seconds: isOnline ? 10 + (index * 8) : 55 + (index * 24),
              ),
            ),
      );
    });

    return ManagerDvr(
      id: id ?? 'dvr_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      site: site.trim(),
      ipAddress: ipAddress.trim(),
      port: port,
      status: _normalizeStatus(status),
      protocol: normalizedProtocol,
      streamProfile: _normalizeProfile(streamProfile),
      notes: notes.trim(),
      updatedAt: DateTime.now(),
      cameras: cameras,
    );
  }

  Future<void> _saveCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    await _saveToPrefs(prefs, dvrs.value);
  }

  List<ManagerDvr> _readFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <ManagerDvr>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ManagerDvr.fromJson)
          .toList()
        ..sort(_compareDvrs);
    } catch (_) {
      return const <ManagerDvr>[];
    }
  }

  Future<void> _saveToPrefs(
    SharedPreferences prefs,
    List<ManagerDvr> entries,
  ) async {
    final encoded = jsonEncode(entries.map((dvr) => dvr.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static int _compareDvrs(ManagerDvr left, ManagerDvr right) {
    final rank = _statusRank(left.status).compareTo(_statusRank(right.status));
    if (rank != 0) {
      return rank;
    }
    return right.updatedAt.compareTo(left.updatedAt);
  }

  static int _statusRank(String status) {
    switch (status) {
      case 'online':
        return 0;
      case 'degraded':
        return 1;
      case 'offline':
        return 2;
      default:
        return 3;
    }
  }

  static bool _cameraOnlineForStatus(String status, int index) {
    switch (_normalizeStatus(status)) {
      case 'online':
        return true;
      case 'degraded':
        return index % 3 != 0;
      case 'offline':
        return false;
      default:
        return false;
    }
  }

  static String _resolutionForProfile(String profile) {
    switch (_normalizeProfile(profile)) {
      case 'HD':
        return '1280x720';
      case '4K':
        return '3840x2160';
      case 'Full HD':
      default:
        return '1920x1080';
    }
  }

  static String _buildLiveUrl(
    String ipAddress,
    int port,
    int channel,
    String protocol,
  ) {
    final normalized = protocol.trim().toLowerCase();
    if (normalized == 'hls') {
      return 'http://$ipAddress:$port/hls/camera_$channel.m3u8';
    }
    if (normalized == 'http' || normalized == 'https') {
      return 'http://$ipAddress:$port/live/camera_$channel.mp4';
    }
    return 'rtsp://$ipAddress:$port/live/ch$channel';
  }

  static String _buildArchiveUrl(String ipAddress, int port, int channel) {
    return 'http://$ipAddress:$port/archive/camera_$channel.m3u8';
  }

  static String _cameraName(int channel) =>
      'CAM-${channel.toString().padLeft(2, '0')}';

  static String _cameraZone(String site, int index) {
    final zones = <String>[
      'Acces principal',
      'Zone de stockage',
      'Couloir technique',
      'Ligne de production',
      'Parking',
      'Salle serveurs',
      'Quai de chargement',
      'Perimetre exterieur',
    ];
    return '${zones[index % zones.length]} - $site';
  }

  static String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static String _normalizeProtocol(String protocol) {
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

  static String _normalizeStatus(String status) {
    final value = status.trim().toLowerCase();
    switch (value) {
      case 'online':
      case 'degraded':
      case 'offline':
        return value;
      default:
        return 'offline';
    }
  }

  static String _normalizeProfile(String profile) {
    final value = profile.trim();
    switch (value) {
      case 'HD':
      case 'Full HD':
      case '4K':
        return value;
      default:
        return 'Full HD';
    }
  }

  String _readFailureMessage({required bool hasCachedData}) {
    if (hasCachedData) {
      return 'Backend indisponible. Affichage du dernier etat synchronise.';
    }
    return 'Impossible de charger les DVR depuis la base de donnees.';
  }

  String _writeFailureMessage(Object error, String fallback) {
    if (error is ApiException) {
      return error.message;
    }
    return fallback;
  }
}
