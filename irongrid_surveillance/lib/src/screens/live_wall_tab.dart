import 'package:flutter/material.dart';

import '../models/surveillance_models.dart';
import '../models/surveillance_view_preset.dart';
import '../widgets/surveillance_shell_widgets.dart';
import '../widgets/surveillance_video_tile.dart';
import '../widgets/surveillance_view_selector.dart';

class LiveWallTab extends StatefulWidget {
  final SurveillanceDashboard dashboard;
  final DateTime now;
  final Future<void> Function() onRefresh;
  final void Function(
    SurveillanceCamera camera,
    List<SurveillanceRecording> recordings,
  ) onOpenCamera;

  const LiveWallTab({
    super.key,
    required this.dashboard,
    required this.now,
    required this.onRefresh,
    required this.onOpenCamera,
  });

  @override
  State<LiveWallTab> createState() => _LiveWallTabState();
}

class _LiveWallTabState extends State<LiveWallTab> {
  SurveillanceViewPreset _preset = SurveillanceViewPreset.quad;
  String? _selectedDvrId;

  @override
  Widget build(BuildContext context) {
    final filteredCameras = _selectedDvrId == null
        ? widget.dashboard.cameras
        : widget.dashboard.cameras
            .where((camera) => camera.dvrId == _selectedDvrId)
            .toList();

    final visibleCameras = filteredCameras.take(_preset.panelCount).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: <Widget>[
          SurveillanceTopHeader(
            title: 'IronGrid Surveillance',
            subtitle:
                'Mur video multi-cameras en temps reel, synchronise avec le backend IronGrid',
            now: widget.now,
            onRefresh: widget.onRefresh,
          ),
          const SizedBox(height: 16),
          SurveillanceHeroBanner(
            dashboard: widget.dashboard,
            now: widget.now,
          ),
          const SizedBox(height: 18),
          SurveillanceViewSelector(
            selectedPreset: _preset,
            onChanged: (preset) {
              setState(() {
                _preset = preset;
              });
            },
            title: 'Affichage simultane',
            subtitle:
                'Choisis 1, 2, 4 ou 8 flux selon le niveau de supervision voulu.',
          ),
          const SizedBox(height: 14),
          _DvrFilterStrip(
            dvrs: widget.dashboard.dvrs,
            selectedDvrId: _selectedDvrId,
            onSelected: (value) {
              setState(() {
                _selectedDvrId = value;
              });
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Vue simultanee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
              ),
              Text(
                '${visibleCameras.length} / ${filteredCameras.length} flux affiches',
                style: const TextStyle(
                  color: Color(0xFF5B6577),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Les cartes affichent uniquement les cameras reelles du DVR selectionne.',
            style: TextStyle(
              color: Color(0xFF5B6577),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (visibleCameras.isEmpty)
            const _EmptyWallState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = _resolveCrossAxisCount(
                  width,
                  visibleCameras.length,
                );
                final extent = _preset.mainAxisExtent(width);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleCameras.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: extent,
                  ),
                  itemBuilder: (context, index) {
                    final camera = visibleCameras[index];
                    return SurveillanceVideoTile(
                      camera: camera,
                      now: widget.now,
                      title: '${camera.name} - ${camera.zone}',
                      onOpenDetail: () =>
                          widget.onOpenCamera(camera, widget.dashboard.recordings),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  int _resolveCrossAxisCount(double width, int cameraCount) {
    final baseCount = _preset.crossAxisCount(width);
    if (cameraCount <= 0) {
      return 1;
    }
    return cameraCount < baseCount ? cameraCount : baseCount;
  }
}

class _DvrFilterStrip extends StatelessWidget {
  final List<SurveillanceDvr> dvrs;
  final String? selectedDvrId;
  final ValueChanged<String?> onSelected;

  const _DvrFilterStrip({
    required this.dvrs,
    required this.selectedDvrId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _FilterChip(
            label: 'Tous les DVR',
            selected: selectedDvrId == null,
            onTap: () => onSelected(null),
          ),
          ...dvrs.map(
            (dvr) => Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _FilterChip(
                label: dvr.name,
                selected: selectedDvrId == dvr.id,
                onTap: () => onSelected(dvr.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF1F3C88) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1F3C88)
                  : const Color(0xFFDCE3F1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF1B2A4A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWallState extends StatelessWidget {
  const _EmptyWallState();

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
            Icons.videocam_off_rounded,
            color: Color(0xFFB42318),
            size: 30,
          ),
          SizedBox(height: 12),
          Text(
            'Aucune camera pour ce DVR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Ajoute des cameras ou choisis un autre DVR pour remplir le mur video.',
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
