import 'package:flutter/material.dart';

import '../models/surveillance_models.dart';
import '../widgets/surveillance_shell_widgets.dart';

class CameraDirectoryTab extends StatelessWidget {
  final SurveillanceDashboard dashboard;
  final Future<void> Function() onRefresh;
  final void Function(
    SurveillanceCamera camera,
    List<SurveillanceRecording> recordings,
  ) onOpenCamera;

  const CameraDirectoryTab({
    super.key,
    required this.dashboard,
    required this.onRefresh,
    required this.onOpenCamera,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: <Widget>[
          SurveillanceTopHeader(
            title: 'Repertoire des cameras',
            subtitle: 'Liste textuelle synchronisee avec la base IronGrid',
            now: DateTime.now(),
            onRefresh: onRefresh,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              SurveillanceSummaryStatCard(
                label: 'DVR',
                value: '${dashboard.dvrs.length}',
                accent: const Color(0xFF1F3C88),
              ),
              SurveillanceSummaryStatCard(
                label: 'Cameras actives',
                value: '${dashboard.onlineCameras}/${dashboard.cameras.length}',
                accent: const Color(0xFF16A34A),
              ),
              SurveillanceSummaryStatCard(
                label: 'Enregistrement',
                value: '${dashboard.recordingCameras}',
                accent: const Color(0xFF2563EB),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...dashboard.dvrs.map(
            (dvr) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFDCE3F1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                dvr.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFF0D1B2A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dvr.site} - ${dvr.networkAddress}',
                                style: const TextStyle(
                                  color: Color(0xFF5B6577),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SurveillanceTinyBadge(
                              label: dvr.statusLabel,
                              color: dvr.status == 'offline'
                                  ? const Color(0xFFDC2626)
                                  : dvr.status == 'degraded'
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF16A34A),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${dvr.cameras.length} camera(s)',
                              style: const TextStyle(
                                color: Color(0xFF5B6577),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (dvr.cameras.isEmpty)
                      const Text(
                        'Aucune camera pour ce DVR.',
                        style: TextStyle(color: Color(0xFF5B6577)),
                      )
                    else
                      ...dvr.cameras.map(
                        (camera) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: const Color(0xFFF7F9FD),
                            borderRadius: BorderRadius.circular(18),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              onTap: () =>
                                  onOpenCamera(camera, dashboard.recordings),
                              leading: CircleAvatar(
                                backgroundColor: camera.isOnline
                                    ? const Color(0xFFDBFCE7)
                                    : const Color(0xFFFEE2E2),
                                child: Icon(
                                  camera.isOnline
                                      ? Icons.videocam_rounded
                                      : Icons.videocam_off_rounded,
                                  color: camera.isOnline
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                              title: Text(
                                '${camera.name} - ${camera.zone}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0D1B2A),
                                ),
                              ),
                              subtitle: Text(
                                'Canal ${camera.channel} - ${camera.resolution} - ${camera.recordingLabel}',
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF1F3C88),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
