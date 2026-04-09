import 'package:flutter/material.dart';

import '../models/surveillance_view_preset.dart';

class SurveillanceViewSelector extends StatelessWidget {
  final SurveillanceViewPreset selectedPreset;
  final ValueChanged<SurveillanceViewPreset> onChanged;
  final String title;
  final String subtitle;

  const SurveillanceViewSelector({
    super.key,
    required this.selectedPreset,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE3F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF5B6577),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: SurveillanceViewPreset.values.map((preset) {
              final selected = preset == selectedPreset;
              return ChoiceChip(
                label: Text('${preset.label} vues'),
                selected: selected,
                onSelected: (_) => onChanged(preset),
                selectedColor: const Color(0xFF1F3C88),
                backgroundColor: const Color(0xFFF3F6FC),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF1F3C88)
                      : const Color(0xFFDCE3F1),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF1B2A4A),
                  fontWeight: FontWeight.w700,
                ),
                avatar: Icon(
                  _iconForPreset(preset),
                  size: 18,
                  color: selected ? Colors.white : const Color(0xFF1F3C88),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _iconForPreset(SurveillanceViewPreset preset) {
    switch (preset) {
      case SurveillanceViewPreset.single:
        return Icons.crop_landscape_rounded;
      case SurveillanceViewPreset.dual:
        return Icons.view_week_rounded;
      case SurveillanceViewPreset.quad:
        return Icons.grid_view_rounded;
      case SurveillanceViewPreset.octa:
        return Icons.dashboard_rounded;
    }
  }
}
