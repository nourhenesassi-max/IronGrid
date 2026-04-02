import 'dart:async';

import 'package:flutter/material.dart';

import '../data/surveillance_repository.dart';
import '../models/surveillance_models.dart';
import '../utils/surveillance_formatters.dart';
import '../widgets/surveillance_video_tile.dart';
import 'recording_detail_screen.dart';

class CameraDetailScreen extends StatefulWidget {
  final SurveillanceCamera camera;
  final List<SurveillanceRecording> recordings;

  const CameraDetailScreen({
    super.key,
    required this.camera,
    required this.recordings,
  });

  @override
  State<CameraDetailScreen> createState() => _CameraDetailScreenState();
}

class _CameraDetailScreenState extends State<CameraDetailScreen> {
  static const Duration _autoRefreshInterval = Duration(seconds: 8);

  final SurveillanceRepository _repository = SurveillanceRepository.instance;

  Timer? _clockTimer;
  Timer? _autoRefreshTimer;

  late SurveillanceCamera _camera;
  late List<SurveillanceRecording> _recordings;
  DateTime _now = DateTime.now();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _camera = widget.camera;
    _recordings = widget.recordings;

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
      });
    });

    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      _refresh(silent: true);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.loadCamera(_camera.id),
        _repository.loadCameraRecordings(_camera.id),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _camera = results[0] as SurveillanceCamera;
        _recordings = results[1] as List<SurveillanceRecording>;
      });
    } catch (error) {
      if (!mounted || silent) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${camera.name} - ${camera.zone}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _isRefreshing ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: <Widget>[
              SurveillanceVideoTile(
                camera: camera,
                now: _now,
                title: 'Vue direct ${camera.name}',
                aspectRatio: 16 / 9,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFDCE3F1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Etat de la camera',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _MetricPill(
                          label: 'Canal',
                          value: '${camera.channel}',
                        ),
                        _MetricPill(
                          label: 'Latence',
                          value: camera.isOnline
                              ? '${camera.latencyMs} ms'
                              : 'Indisponible',
                        ),
                        _MetricPill(
                          label: 'Bitrate',
                          value: '${camera.bitrateKbps} kbps',
                        ),
                        _MetricPill(
                          label: 'Resolution',
                          value: camera.resolution,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${camera.dvrName} - ${camera.statusLabel} - ${camera.recordingLabel}',
                      style: const TextStyle(
                        color: Color(0xFF51607A),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Enregistrements recents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                  ),
                  Text(
                    '${_recordings.length} sequence(s)',
                    style: const TextStyle(
                      color: Color(0xFF5B6577),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_recordings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFDCE3F1)),
                  ),
                  child: const Text(
                    'Aucun enregistrement pour cette camera.',
                    style: TextStyle(color: Color(0xFF5B6577)),
                  ),
                )
              else
                ..._recordings.map(
                  (recording) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecordingCard(
                      recording: recording,
                      onTap: () => _openRecording(recording),
                    ),
                  ),
                ),
            ],
          ),
          if (_isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: Color(0xFF1F3C88),
                backgroundColor: Color(0xFFE3ECFF),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openRecording(SurveillanceRecording recording) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecordingDetailScreen(
          recording: recording,
          now: _now,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6A7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0D1B2A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  final SurveillanceRecording recording;
  final VoidCallback onTap;

  const _RecordingCard({
    required this.recording,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDCE3F1)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF1F3C88),
                      Color(0xFF3A63C7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      recording.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${SurveillanceFormatters.dateTime(recording.startedAt)} - ${recording.durationLabel}',
                      style: const TextStyle(
                        color: Color(0xFF51607A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF1F3C88),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
