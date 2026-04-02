import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/employee_models.dart';

class TimeTrackingCardWidget extends StatelessWidget {
  final AttendanceCardData data;
  final List<String> lines;
  final String selectedLine;
  final ValueChanged<String> onLineChanged;
  final VoidCallback onPrimaryAction;
  final bool isLoading;

  const TimeTrackingCardWidget({
    super.key,
    required this.data,
    required this.lines,
    required this.selectedLine,
    required this.onLineChanged,
    required this.onPrimaryAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusUI = _statusPresentation(data.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Suivi du Temps",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatusBadge(
                label: statusUI.label,
                color: statusUI.color,
                icon: statusUI.icon,
              ),
              const Spacer(),
              if (data.lastEventLabel != null)
                Flexible(
                  child: Text(
                    data.lastEventLabel!,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: "Aujourd'hui",
                  value: data.todayWorked,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  title: "Cette Semaine",
                  value: data.weekWorked,
                ),
              ),
            ],
          ),
          if (data.anomalyMessage != null) ...[
            const SizedBox(height: 12),
            _WarningBox(message: data.anomalyMessage!),
          ],
          const SizedBox(height: 12),
          AbsorbPointer(
            absorbing: !data.canSelectLine || isLoading,
            child: Opacity(
              opacity: (!data.canSelectLine || isLoading) ? 0.6 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textMuted.withOpacity(0.15),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLine,
                    isExpanded: true,
                    items: lines
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => onLineChanged(v ?? selectedLine),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onPrimaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: statusUI.buttonColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.textMuted.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(data.primaryActionIcon),
              label: Text(
                data.primaryActionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusPresentation _statusPresentation(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.notStarted:
        return const _StatusPresentation(
          label: 'Non pointé',
          color: Colors.grey,
          buttonColor: AppColors.primary,
          icon: Icons.radio_button_unchecked,
        );
      case AttendanceStatus.working:
        return const _StatusPresentation(
          label: 'En service',
          color: Colors.green,
          buttonColor: Colors.red,
          icon: Icons.play_circle_fill,
        );
      case AttendanceStatus.onBreak:
        return const _StatusPresentation(
          label: 'En pause',
          color: Colors.orange,
          buttonColor: Colors.green,
          icon: Icons.pause_circle_filled,
        );
      case AttendanceStatus.incomplete:
        return const _StatusPresentation(
          label: 'Incomplet',
          color: Colors.red,
          buttonColor: Colors.orange,
          icon: Icons.error,
        );
      case AttendanceStatus.pendingValidation:
        return const _StatusPresentation(
          label: 'À valider',
          color: Colors.blue,
          buttonColor: Colors.blueGrey,
          icon: Icons.schedule,
        );
    }
  }
}

class _StatusPresentation {
  final String label;
  final Color color;
  final Color buttonColor;
  final IconData icon;

  const _StatusPresentation({
    required this.label,
    required this.color,
    required this.buttonColor,
    required this.icon,
  });
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String message;

  const _WarningBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}