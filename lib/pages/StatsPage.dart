import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_data.dart';
import '../models/StatsModel.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String selectedPeriod = 'day';
  int _getDaysFromPeriod() {
  switch (selectedPeriod) {
    case 'day': return 1;
    case 'week': return 7;
    case 'month': return 30;
    default: return 7;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1010),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Estatísticas',
          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDropdown(),
              const SizedBox(height: 16),
              ...AppData.getStatsOfLastDays(_getDaysFromPeriod()).map((s) => _buildStatCard(s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: selectedPeriod,
        dropdownColor: Colors.grey[900],
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        items: const [
          DropdownMenuItem(value: 'day', child: Text("Hoje")),
          DropdownMenuItem(value: 'week', child: Text("Essa Semana")),
          DropdownMenuItem(value: 'month', child: Text("Esse Mês")),
        ],
        onChanged: (value) {
          setState(() => selectedPeriod = value!);
        },
      ),
    );
  }

  Widget _buildStatCard(StatsModel stat) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: const Color.fromARGB(7, 0, 0, 0), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(stat.icon, color: stat.color),
          SizedBox(width: 12),
          Text(stat.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        SizedBox(height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: selectedPeriod == 'day'
              ? PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(
                        value: (stat.data.isNotEmpty && stat.goal > 0)
                            ? (stat.data.first / stat.goal).clamp(0.0, 1.0)
                            : 0.0,
                        color: stat.color,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: stat.data.isNotEmpty
                            ? (1 - (stat.data.first / stat.goal)).clamp(0.0, 1.0)
                            : 1.0,
                        color: const Color.fromARGB(183, 125, 125, 125),
                        radius: 20,
                        showTitle: false,
                      ),
                    ],
                  ),
                )
              : LineChart(
                  LineChartData(
                    minY: stat.isPercentage ? 0.0 : null,
                    maxY: stat.isPercentage ? 1.1 : null,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          interval: stat.title == "Dias Ativos" ? 1.0 : null,
                          getTitlesWidget: (value, meta) {
                            if (stat.title == "Dias Ativos") {
                              String label = value >= 0.5 ? "Ativo" : "Inativo";
                              return Text(label,
                                  style: const TextStyle(color: Colors.white54, fontSize: 11));
                            }

                            final displayValue = stat.isPercentage
                                ? (value * 100).toInt().toString()
                                : value.toStringAsFixed(1);

                            return Text("$displayValue ${stat.unit}",
                                style: const TextStyle(color: Colors.white54, fontSize: 11));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < stat.labels.length) {
                              return Text(stat.labels[index],
                                  style: const TextStyle(color: Colors.white54, fontSize: 12));
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: stat.color,
                        belowBarData: BarAreaData(
                          show: true,
                          color: stat.color.withOpacity(0.3),
                        ),
                        dotData: FlDotData(show: false),
                        spots: stat.data.asMap().entries.map(
                              (e) => FlSpot(e.key.toDouble(), e.value),
                            ).toList(),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    ),
  );
}
}
