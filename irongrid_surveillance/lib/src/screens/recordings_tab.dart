import 'package:flutter/material.dart';

import '../models/surveillance_models.dart';
import '../models/surveillance_view_preset.dart';
import '../utils/surveillance_formatters.dart';
import '../widgets/surveillance_archive_tile.dart';
import '../widgets/surveillance_shell_widgets.dart';
import '../widgets/surveillance_view_selector.dart';

class RecordingsTab extends StatefulWidget {
  final SurveillanceDashboard dashboard;
  final DateTime now;
  final Future<void> Function() onRefresh;
  final void Function(SurveillanceRecording recording) onOpenRecording;

  const RecordingsTab({
    super.key,
    required this.dashboard,
    required this.now,
    required this.onRefresh,
    required this.onOpenRecording,
  });

  @override
  State<RecordingsTab> createState() => _RecordingsTabState();
}

class _RecordingsTabState extends State<RecordingsTab> {
  SurveillanceViewPreset _preset = SurveillanceViewPreset.dual;

  @override
  Widget build(BuildContext context) {
    final visibleRecordings =
        widget.dashboard.recordings.take(_preset.panelCount).toList();
    final latestDvrName = widget.dashboard.dvrs.isEmpty
        ? 'Aucun'
        : widget.dashboard.dvrs.first.name;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: <Widget>[
          SurveillanceTopHeader(
            title: 'Centre des archives',
            subtitle:
                'Lecture multi-enregistrements ou lecture detaillee par camera',
            now: widget.now,
            onRefresh: widget.onRefresh,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFDCE3F1)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SurveillanceArchiveMetric(
                    label: 'Sequences',
                    value: '${widget.dashboard.recordings.length}',
                  ),
                ),
                Expanded(
                  child: SurveillanceArchiveMetric(
                    label: 'Dernier DVR',
                    value: latestDvrName,
                  ),
                ),
                Expanded(
                  child: SurveillanceArchiveMetric(
                    label: 'Derniere heure',
                    value: SurveillanceFormatters.clock(widget.now),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SurveillanceViewSelector(
            selectedPreset: _preset,
            onChanged: (preset) {
              setState(() {
                _preset = preset;
              });
            },
            title: 'Mur d enregistrements',
            subtitle:
                'Affiche 1, 2, 4 ou 8 archives a la fois pour comparer les sequences.',
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Lecture simultanee des archives',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
              ),
              Text(
                '${visibleRecordings.length} / ${widget.dashboard.recordings.length}',
                style: const TextStyle(
                  color: Color(0xFF5B6577),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Le mur affiche uniquement les archives reelles renvoyees par le backend.',
            style: TextStyle(
              color: Color(0xFF5B6577),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (visibleRecordings.isEmpty)
            const _EmptyRecordingsState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = _resolveCrossAxisCount(
                  width,
                  visibleRecordings.length,
                );
                final extent = _preset.mainAxisExtent(width);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleRecordings.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: extent,
                  ),
                  itemBuilder: (context, index) {
                    final recording = visibleRecordings[index];
                    return SurveillanceArchiveTile(
                      recording: recording,
                      now: widget.now,
                      onOpenDetail: () => widget.onOpenRecording(recording),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 20),
          const Text(
            'Journal des enregistrements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.dashboard.recordings.map(
            (recording) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: () => widget.onOpenRecording(recording),
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
                          width: 58,
                          height: 58,
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
                            size: 28,
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
                                '${recording.cameraName} - ${recording.dvrName}',
                                style: const TextStyle(
                                  color: Color(0xFF51607A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${SurveillanceFormatters.dateTime(recording.startedAt)} - ${recording.durationLabel} - ${recording.sizeLabel}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _resolveCrossAxisCount(double width, int itemCount) {
    final baseCount = _preset.crossAxisCount(width);
    if (itemCount <= 0) {
      return 1;
    }
    return itemCount < baseCount ? itemCount : baseCount;
  }
}

class _EmptyRecordingsState extends StatelessWidget {
  const _EmptyRecordingsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE3F1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.video_library_outlined,
            color: Color(0xFF1F3C88),
            size: 30,
          ),
          SizedBox(height: 12),
          Text(
            'Aucune archive disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Les enregistrements apparaitront ici des que le backend en remontera.',
            style: TextStyle(
              color: Color(0xFF5B6577),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
