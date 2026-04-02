import 'dart:async';

import 'package:flutter/material.dart';

import '../data/surveillance_repository.dart';
import '../models/surveillance_models.dart';
import '../services/surveillance_session_bridge.dart';
import 'camera_detail_screen.dart';
import 'camera_directory_tab.dart';
import 'live_wall_tab.dart';
import 'recording_detail_screen.dart';
import 'recordings_tab.dart';

class SurveillanceHomeScreen extends StatefulWidget {
  const SurveillanceHomeScreen({super.key});

  @override
  State<SurveillanceHomeScreen> createState() => _SurveillanceHomeScreenState();
}

class _SurveillanceHomeScreenState extends State<SurveillanceHomeScreen>
    with WidgetsBindingObserver {
  static const Duration _autoRefreshInterval = Duration(seconds: 8);

  final SurveillanceRepository _repository = SurveillanceRepository.instance;
  final SurveillanceSessionBridge _sessionBridge =
      SurveillanceSessionBridge.instance;

  Timer? _clockTimer;
  Timer? _autoRefreshTimer;
  StreamSubscription<void>? _sessionSubscription;

  SurveillanceDashboard? _dashboard;
  Object? _loadError;
  DateTime _now = DateTime.now();
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _refresh(
      silent: true,
      forceLoader: true,
    );

    _sessionSubscription = _sessionBridge.updates.listen((_) {
      if (!mounted) {
        return;
      }
      _refresh(silent: true);
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
      });
    });

    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (!mounted) {
        return;
      }
      _refresh(silent: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh(silent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionSubscription?.cancel();
    _clockTimer?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({
    bool silent = false,
    bool forceLoader = false,
  }) async {
    if (_isRefreshing) {
      return;
    }

    if (mounted) {
      setState(() {
        if (_dashboard == null || forceLoader) {
          _isLoading = true;
        }
        _isRefreshing = true;
      });
    } else {
      _isRefreshing = true;
      if (_dashboard == null || forceLoader) {
        _isLoading = true;
      }
    }

    try {
      await _sessionBridge.initialize();
      final dashboard = await _repository.loadDashboard();

      if (!mounted) {
        _dashboard = dashboard;
        _loadError = null;
        _isLoading = false;
        _isRefreshing = false;
        return;
      }

      setState(() {
        _dashboard = dashboard;
        _loadError = null;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (error) {
      if (!mounted) {
        _loadError = error;
        _isLoading = false;
        _isRefreshing = false;
        return;
      }

      setState(() {
        if (_dashboard == null) {
          _loadError = error;
          _isLoading = false;
        }
        _isRefreshing = false;
      });

      if (!silent && _dashboard != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboard;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: _buildBody(dashboard),
      ),
      bottomNavigationBar: dashboard == null
          ? null
          : NavigationBar(
              height: 76,
              selectedIndex: _currentIndex,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFF1F3C88).withValues(alpha: 0.14),
              onDestinationSelected: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  selectedIcon: Icon(Icons.dashboard_customize_rounded),
                  label: 'Mur video',
                ),
                NavigationDestination(
                  icon: Icon(Icons.videocam_outlined),
                  selectedIcon: Icon(Icons.videocam_rounded),
                  label: 'Cameras',
                ),
                NavigationDestination(
                  icon: Icon(Icons.video_library_outlined),
                  selectedIcon: Icon(Icons.video_library_rounded),
                  label: 'Archives',
                ),
              ],
            ),
    );
  }

  Widget _buildBody(SurveillanceDashboard? dashboard) {
    if (_isLoading && dashboard == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (dashboard == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Color(0xFFB42318),
              ),
              const SizedBox(height: 12),
              const Text(
                'Impossible de charger la supervision.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_loadError ?? 'Une erreur est survenue.'}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF5B6577)),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        _buildCurrentTab(dashboard),
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
    );
  }

  Widget _buildCurrentTab(SurveillanceDashboard dashboard) {
    if (_currentIndex == 0) {
      return LiveWallTab(
        dashboard: dashboard,
        now: _now,
        onRefresh: _refresh,
        onOpenCamera: _openCamera,
      );
    }

    if (_currentIndex == 1) {
      return CameraDirectoryTab(
        dashboard: dashboard,
        onRefresh: _refresh,
        onOpenCamera: _openCamera,
      );
    }

    return RecordingsTab(
      dashboard: dashboard,
      now: _now,
      onRefresh: _refresh,
      onOpenRecording: _openRecording,
    );
  }

  void _openCamera(
    SurveillanceCamera camera,
    List<SurveillanceRecording> recordings,
  ) {
    final matchingRecordings = recordings
        .where((recording) => recording.cameraId == camera.id)
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraDetailScreen(
          camera: camera,
          recordings: matchingRecordings,
        ),
      ),
    );
  }

  void _openRecording(SurveillanceRecording recording) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecordingDetailScreen(
          recording: recording,
          now: _now,
        ),
      ),
    );
  }
}
