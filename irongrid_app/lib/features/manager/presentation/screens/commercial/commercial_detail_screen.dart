import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CommercialDetailScreen extends StatefulWidget {
  final String title;
  final String amount;

  const CommercialDetailScreen({
    super.key,
    required this.title,
    required this.amount,
  });

  @override
  State<CommercialDetailScreen> createState() => _CommercialDetailScreenState();
}

class _CommercialDetailScreenState extends State<CommercialDetailScreen> {
  int touchedIndex = -1;

  static const Color _backgroundColor = Color(0xFFF7F8FC);
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  final List<_ClientRevenue> clients = const [
    _ClientRevenue('CL1', 8500, Color(0xFF1D4ED8)),
    _ClientRevenue('CL2', 7200, Color(0xFF3B82F6)),
    _ClientRevenue('CL3', 9150, Color(0xFF93C5FD)),
  ];

  @override
  Widget build(BuildContext context) {
    final total = clients.fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _backgroundColor,
        foregroundColor: _textPrimary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            _buildAmountCard(),
            const SizedBox(height: 18),
            _buildPieChartCard(total),
            const SizedBox(height: 18),
            ...clients.map((client) {
              final percent = (client.amount / total) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildClientTile(client, percent),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            'Montant total',
            style: TextStyle(
              fontSize: 13.5,
              color: _textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.amount,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Répartition par client',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 58,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: List.generate(clients.length, (index) {
                      final client = clients[index];
                      final isTouched = index == touchedIndex;
                      final percentage = (client.amount / total) * 100;

                      return PieChartSectionData(
                        color: client.color,
                        value: client.amount,
                        radius: isTouched ? 74 : 64,
                        title: '${percentage.toStringAsFixed(0)}%',
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 16 : 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Clients',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${clients.length}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
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

  Widget _buildClientTile(_ClientRevenue client, double percent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: client.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              client.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          Text(
            '${client.amount.toStringAsFixed(0)} €',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: client.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: client.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientRevenue {
  final String label;
  final double amount;
  final Color color;

  const _ClientRevenue(this.label, this.amount, this.color);
}