import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/reading.dart';
import '../models/forecast.dart';

class PowerChartCard extends StatelessWidget {
  final List<Reading> readings;
  final List<Forecast> forecasts;
  final String filter;

  const PowerChartCard({
    super.key,
    required this.readings,
    this.forecasts = const [],
    this.filter = '60m',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.zap, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Live Power Usage (Last Hour)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: readings.isEmpty && forecasts.isEmpty
                  ? const Center(
                      child: Text(
                        'Waiting for data...',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : _buildChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    DateTime? minTime;
    DateTime? maxTime;

    if (readings.isNotEmpty) {
      minTime = readings.first.timestamp;
      maxTime = readings.last.timestamp;
    }
    if (forecasts.isNotEmpty) {
      if (minTime == null || forecasts.first.time.isBefore(minTime)) {
        minTime = forecasts.first.time;
      }
      if (maxTime == null || forecasts.last.time.isAfter(maxTime)) {
        maxTime = forecasts.last.time;
      }
    }

    if (minTime == null || maxTime == null) return const SizedBox();

    double getX(DateTime t) => t.difference(minTime!).inMinutes.toDouble();
    double maxX = getX(maxTime);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.white10,
              strokeWidth: 1,
              dashArray: [3, 3],
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Colors.white10,
              strokeWidth: 1,
              dashArray: [3, 3],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (maxX > 0 ? maxX / 5 : 1).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final time = minTime!.add(Duration(minutes: value.toInt()));
                String formattedTime = '';

                if (filter == '60m') {
                  formattedTime = DateFormat('HH:mm').format(time.toLocal());
                } else if (filter == 'hourly') {
                  formattedTime = DateFormat(
                    'ha',
                  ).format(time.toLocal()); // e.g., 5PM
                } else if (filter == 'daily') {
                  formattedTime = DateFormat(
                    'MMM d',
                  ).format(time.toLocal()); // e.g., Oct 12
                }

                return Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxX,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: readings.map((e) {
              return FlSpot(getX(e.timestamp), e.power.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.greenAccent,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent.withValues(alpha: 0.3),
                  Colors.greenAccent.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          if (forecasts.isNotEmpty) ...[
            LineChartBarData(
              spots: forecasts.where((f) => getX(f.time) <= maxX).map((e) {
                return FlSpot(getX(e.time), e.expectedPower);
              }).toList(),
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
            LineChartBarData(
              spots: forecasts.where((f) => getX(f.time) <= maxX).map((e) {
                return FlSpot(getX(e.time), e.spikeThreshold);
              }).toList(),
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
          ],
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y} W',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
