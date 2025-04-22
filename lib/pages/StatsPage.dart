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

  MapEntry<String, Color> _getBmiLabel(double bmi) {
  if (bmi < 10) return MapEntry("Não Calculado", Colors.grey);
  if (bmi < 18.5) return MapEntry("Abaixo do peso", Colors.orangeAccent);
  if (bmi < 25) return MapEntry("Normal", Colors.greenAccent);
  if (bmi < 30) return MapEntry("Sobrepeso", Colors.yellow);
  if (bmi < 35) return MapEntry("Obesidade I", Colors.orange);
  if (bmi < 40) return MapEntry("Obesidade II", Colors.deepOrange);
  return MapEntry("Obesidade III", Colors.red);
}

void _showBmiDialog() {
  final alturaController = TextEditingController();
  final pesoController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Calcular IMC", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: alturaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Altura (m)",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Peso (kg)",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Calcular", style: TextStyle(color: Colors.greenAccent)),
            onPressed: () {
              final altura = double.tryParse(alturaController.text);
              final peso = double.tryParse(pesoController.text);

              if (altura != null && peso != null && altura > 0) {
                final bmi = peso / (altura * altura);
                AppData.setBmi(bmi); // Crie esse método em AppData, explico abaixo.
                Navigator.pop(context);
                setState(() {}); // Atualiza a UI
              }
            },
          ),
        ],
      );
    },
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
    final bmi = _getBmiLabel(stat.data.first);
    final bmiText = bmi.key;
    final bmiColor = bmi.value;

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
        if (stat.isBmi && selectedPeriod == 'day') ...[ 
          SizedBox(width: 300, height: 200,
          child: 
          InkWell(
            onTap: () {
              if (stat.data.isEmpty) {
                _showBmiDialog();
              }
            },
            child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: 
            stat.data.isEmpty ? 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Text("Não calculado", style: const TextStyle(color: Colors.white70, fontSize: 20)),
              Text('Clique aqui para calcular', style: const TextStyle(color: Colors.white70, fontSize: 12))
            ],):
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: bmiColor, width: 4),
                    color: Colors.transparent, // ou qualquer cor de fundo, tipo Colors.black45
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    stat.data.first.toStringAsFixed(1),
                    style: TextStyle(color: bmiColor, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                Text(bmiText, style:  TextStyle(color: bmiColor, fontSize: 20))
              ]
            )
            )
            ),)

      
    ] else ...[
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
        ),]
      ],
    ),
  );
}
}
