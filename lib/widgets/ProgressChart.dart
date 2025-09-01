import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


// barra de progresso
class ProgressChart extends StatelessWidget {
  final List<double> values;

  const ProgressChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  List<String> days = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  }
                  return const Text('');
                },
                interval: 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                values.length,
                (index) => FlSpot(index.toDouble(), values[index]),
              ),
              isCurved: true,
              color: Colors.tealAccent,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }
}
