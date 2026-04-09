import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_surveillance_model.dart';

class ManagerCameraStreamPanel extends StatefulWidget {
  final ManagerCameraFeed camera;
  final String title;
  final String actionLabel;
  final VoidCallback? onOpenFullscreen;

  const ManagerCameraStreamPanel({
    super.key,
    required this.camera,
    required this.title,
    required this.actionLabel,
    this.onOpenFullscreen,
  });

  @override
  State<ManagerCameraStreamPanel> createState() =>
      _ManagerCameraStreamPanelState();
}

class _ManagerCameraStreamPanelState extends State<ManagerCameraStreamPanel> {
  VlcPlayerController? _controller;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant ManagerCameraStreamPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.camera.streamUrl != widget.camera.streamUrl) {
      _disposeController();
      _initController();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _initController() {
    if (!widget.camera.hasLiveStream) {
      return;
    }

    final controller = VlcPlayerController.network(
      widget.camera.streamUrl,
      autoInitialize: true,
      autoPlay: true,
      hwAcc: HwAcc.auto,
    );

    setState(() {
      _controller = controller;
    });
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    _muted = !_muted;
    await controller.setVolume(_muted ? 0 : 100);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.camera;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 228,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              color: AppColors.textDark,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _controller == null
                      ? _PlayerPlaceholder(camera: camera)
                      : VlcPlayer(
                          controller: _controller!,
                          aspectRatio: 16 / 9,
                          placeholder: _PlayerPlaceholder(camera: camera),
                        ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _LiveBadge(camera: camera),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Row(
                    children: [
                      _OverlayButton(
                        icon: _controller?.value.isPlaying ?? false
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onTap: _togglePlayback,
                      ),
                      const SizedBox(width: 8),
                      _OverlayButton(
                        icon: _muted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        onTap: _toggleMute,
                      ),
                      if (widget.onOpenFullscreen != null) ...[
                        const SizedBox(width: 8),
                        _OverlayButton(
                          icon: Icons.open_in_full_rounded,
                          onTap: widget.onOpenFullscreen!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (widget.onOpenFullscreen != null)
                      TextButton.icon(
                        onPressed: widget.onOpenFullscreen,
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(widget.actionLabel),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  camera.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  camera.zone,
                  style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  camera.streamUrl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.88),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManagerCameraPlaybackScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String sourceUrl;

  const ManagerCameraPlaybackScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sourceUrl,
  });

  @override
  Widget build(BuildContext context) {
    final fakeCamera = ManagerCameraFeed(
      id: 'playback',
      name: title,
      zone: subtitle,
      channel: 0,
      isOnline: true,
      recordingEnabled: true,
      motionEnabled: false,
      resolution: 'Live',
      bitrateKbps: 0,
      latencyMs: 0,
      streamUrl: sourceUrl,
      archiveUrl: '',
      previewImageUrl: '',
      streamType: 'network',
      lastHeartbeatAt: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ManagerCameraStreamPanel(
            camera: fakeCamera,
            title: 'Lecture plein ecran',
            actionLabel: 'Lecture',
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sourceUrl,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final ManagerCameraFeed camera;

  const _LiveBadge({required this.camera});

  @override
  Widget build(BuildContext context) {
    final color =
        camera.isOnline ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            camera.isOnline ? 'LIVE' : 'OFFLINE',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.36),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _PlayerPlaceholder extends StatelessWidget {
  final ManagerCameraFeed camera;

  const _PlayerPlaceholder({
    required this.camera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textDark,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.live_tv_outlined,
                color: Colors.white.withValues(alpha: 0.92),
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                camera.hasLiveStream
                    ? 'Flux en cours de chargement...'
                    : 'URL de stream absente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                camera.hasLiveStream
                    ? 'Le player est pret pour RTSP, HLS et liens HTTP reels.'
                    : 'Le backend doit renvoyer streamUrl ou liveUrl pour lire la camera.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
