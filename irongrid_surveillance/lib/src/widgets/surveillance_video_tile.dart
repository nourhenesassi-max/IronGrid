import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import '../models/surveillance_models.dart';

class SurveillanceVideoTile extends StatefulWidget {
  final SurveillanceCamera camera;
  final DateTime now;
  final VoidCallback? onOpenDetail;
  final String? title;
  final double aspectRatio;

  const SurveillanceVideoTile({
    super.key,
    required this.camera,
    required this.now,
    this.onOpenDetail,
    this.title,
    this.aspectRatio = 16 / 10,
  });

  @override
  State<SurveillanceVideoTile> createState() => _SurveillanceVideoTileState();
}

class _SurveillanceVideoTileState extends State<SurveillanceVideoTile> {
  VlcPlayerController? _controller;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant SurveillanceVideoTile oldWidget) {
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

    Future<void>.microtask(() => controller.setVolume(0));

    _controller = controller;
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
    final controller = _controller;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDCE3F1)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140D1B2A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF071226),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (controller != null)
                    VlcPlayer(
                      controller: controller,
                      aspectRatio: widget.aspectRatio,
                      placeholder: _StreamPlaceholder(camera: camera),
                    )
                  else
                    _StreamPlaceholder(camera: camera),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(
                      label: camera.isOnline ? 'LIVE' : 'OFFLINE',
                      color: camera.isOnline
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            _formatClock(widget.now),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(widget.now),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      children: <Widget>[
                        _OverlayIconButton(
                          icon: controller?.value.isPlaying ?? false
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: _togglePlayback,
                        ),
                        const SizedBox(width: 8),
                        _OverlayIconButton(
                          icon: _muted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          onTap: _toggleMute,
                        ),
                        const Spacer(),
                        if (widget.onOpenDetail != null)
                          _OverlayIconButton(
                            icon: Icons.open_in_full_rounded,
                            onTap: widget.onOpenDetail!,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title ?? camera.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ),
                    if (widget.onOpenDetail != null)
                      TextButton.icon(
                        onPressed: widget.onOpenDetail,
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Details'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${camera.dvrName} · ${camera.zone}',
                  style: const TextStyle(
                    color: Color(0xFF5B6577),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _InfoChip(icon: Icons.videocam_outlined, label: camera.statusLabel),
                    _InfoChip(icon: Icons.memory_rounded, label: camera.resolution),
                    _InfoChip(
                      icon: Icons.speed_rounded,
                      label:
                          camera.isOnline ? '${camera.latencyMs} ms' : 'Indisponible',
                    ),
                    _InfoChip(
                      icon: Icons.album_rounded,
                      label: camera.recordingLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _StreamPlaceholder extends StatelessWidget {
  final SurveillanceCamera camera;

  const _StreamPlaceholder({required this.camera});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFF09182F),
            Color(0xFF102646),
            Color(0xFF1C3761),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              camera.hasLiveStream
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              color: Colors.white.withValues(alpha: 0.92),
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              camera.hasLiveStream
                  ? 'Chargement du flux...'
                  : 'Flux direct indisponible',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              camera.name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: const Color(0xFF1F3C88)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1B2A4A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
