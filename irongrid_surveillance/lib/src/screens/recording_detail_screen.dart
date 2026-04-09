import 'package:flutter/material.dart';

import '../models/surveillance_models.dart';
import '../utils/surveillance_formatters.dart';
import '../widgets/surveillance_archive_tile.dart';

class RecordingDetailScreen extends StatelessWidget {
  final SurveillanceRecording recording;
  final DateTime now;

  const RecordingDetailScreen({
    super.key,
    required this.recording,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${recording.cameraName} - Archive',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: <Widget>[
          SurveillanceArchiveTile(
            recording: recording,
            now: now,
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
                  'Details de lecture',
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
                      label: 'Debut',
                      value: SurveillanceFormatters.dateTime(recording.startedAt),
                    ),
                    _MetricPill(
                      label: 'Fin',
                      value: SurveillanceFormatters.dateTime(recording.endedAt),
                    ),
                    _MetricPill(
                      label: 'Duree',
                      value: recording.durationLabel,
                    ),
                    _MetricPill(
                      label: 'Taille',
                      value: recording.sizeLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${recording.dvrName} - ${recording.trigger}',
                  style: const TextStyle(
                    color: Color(0xFF51607A),
                    height: 1.4,
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
      width: 160,
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
