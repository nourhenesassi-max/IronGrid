import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProductionAnalysisSectionEmployee extends StatelessWidget {
  final String period;
  final String mode;
  final DateTime selectedDate;

  const ProductionAnalysisSectionEmployee({
    super.key,
    required this.period,
    required this.mode,
    required this.selectedDate,
  });

  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final labels = _getLabels(period, mode);
    final values = _getValues(period, mode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
            'Analyse de performance',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$mode • $period • ${_formatDate(selectedDate)}',
            style: const TextStyle(
              fontSize: 12.5,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: 100,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(values.length, (index) {
                  final value = values[index];

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        color: value >= 80
                            ? const Color(0xFF16A34A)
                            : value >= 60
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFDC2626),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getLabels(String period, String mode) {
    if (mode == 'Atelier') {
      return ['A1', 'A2', 'A3', 'A4', 'A5'];
    } else {
      return ['C1', 'C2', 'C3', 'C4', 'C5'];
    }
  }

  List<double> _getValues(String period, String mode) {
    if (mode == 'Atelier') {
      switch (period) {
        case "Aujourd'hui":
          return [86, 74, 91, 68, 80];
        case 'S-1':
          return [81, 79, 84, 72, 77];
        case 'M-1':
          return [78, 75, 70, 82, 76];
        default:
          return [80, 76, 82, 70, 78];
      }
    } else {
      switch (period) {
        case "Aujourd'hui":
          return [88, 71, 83, 66, 92];
        case 'S-1':
          return [76, 81, 79, 69, 85];
        case 'M-1':
          return [74, 77, 73, 80, 78];
        default:
          return [78, 75, 80, 70, 82];
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}