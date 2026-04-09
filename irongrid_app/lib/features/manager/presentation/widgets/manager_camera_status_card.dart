import 'package:flutter/material.dart';

import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_surveillance_model.dart';

class ManagerCameraStatusCard extends StatelessWidget {
  final ManagerCameraFeed camera;
  final bool isBusy;
  final ValueChanged<bool> onToggleOnline;

  const ManagerCameraStatusCard({
    super.key,
    required this.camera,
    required this.isBusy,
    required this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        camera.isOnline ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      camera.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      camera.zone,
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.92),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _CameraStatusChip(
                color: statusColor,
                label: camera.statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _DetailChip(label: 'Canal ${camera.channel}'),
              _DetailChip(label: camera.resolution),
              _DetailChip(label: camera.latencyLabel),
              _DetailChip(
                label: camera.recordingEnabled ? 'Rec ON' : 'Rec OFF',
              ),
              _DetailChip(
                label: camera.motionEnabled ? 'Motion ON' : 'Motion OFF',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Etat de la camera',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        camera.isOnline
                            ? 'Cette camera est disponible en direct et remonte au backend.'
                            : 'Cette camera est coupee pour toute la supervision.',
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.94),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                isBusy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Switch.adaptive(
                        value: camera.isOnline,
                        activeTrackColor: const Color(0xFF16A34A),
                        onChanged: onToggleOnline,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraStatusChip extends StatelessWidget {
  final Color color;
  final String label;

  const _CameraStatusChip({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;

  const _DetailChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
