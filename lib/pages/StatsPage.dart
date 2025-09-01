import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vital/pages/DeluxePage.dart';
import '../app_data.dart';
import '../models/StatsModel.dart';
import 'package:vital/themeNotifier.dart';
import 'package:provider/provider.dart';

// tela de stats

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String selectedPeriod = 'day'; // periodo selecionado
  
  // seleciona o periodo 
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
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppData.isExclusiveTheme ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Estatísticas',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: 
      
      Stack(
        children: [
          Consumer<ThemeNotifier>(builder: (context, themeNotifier, child){
        if (!AppData.isExclusiveTheme) {
      return const SizedBox.shrink(); // Não mostra nada
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(themeNotifier.currentTheme.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7), // 👈 escurece a imagem
            BlendMode.darken,
          ),
        ),
      ),
    );
    },),
          SafeArea(
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
        ],
      )
    );
  }

  // calcula o imc
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
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Calcular IMC", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: alturaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Altura (m)",
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Peso (kg)",
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
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
              final altura = double.tryParse(alturaController.text.trim().replaceAll(',', '.'));
              final peso = double.tryParse(pesoController.text.trim().replaceAll(',', '.'));

              if (altura != null && peso != null && altura > 0) {
                final bmi = peso / (altura * altura);
                AppData.setBmi(bmi); 
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
  return GestureDetector(
    onTap: () {
      if (AppData.ultimate) {
        _showDropdownMenu(); // abre as opções manualmente
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Deluxepage()));
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getPeriodLabel(selectedPeriod),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
    ),
  );
}

void _showDropdownMenu() async {
  final value = await showMenu<String>(
    context: context,
    position: const RelativeRect.fromLTRB(100, 100, 100, 100),
    items: const [
      PopupMenuItem(value: 'day', child: Text("Hoje")),
      PopupMenuItem(value: 'week', child: Text("Essa Semana")),
      PopupMenuItem(value: 'month', child: Text("Esse Mês")),
    ],
  );

  if (value != null) {
    setState(() => selectedPeriod = value);
  }
}

String _getPeriodLabel(String value) {
  switch (value) {
    case 'day':
      return 'Hoje';
    case 'week':
      return 'Essa Semana';
    case 'month':
      return 'Esse Mês';
    default:
      return '';
  }
}

  Widget _buildStatCard(StatsModel stat) {
    late final String bmiText;
    late final Color bmiColor;
    final isLitros = stat.goal == 2000.0;
    final isHours = stat.goal == 8;
    final valorAtual = isLitros ? stat.data.first / 1000 : stat.data.first;
    final valorMeta = isLitros ? stat.goal / 1000 : stat.goal;
    final unidade = isLitros ? 'L' : isHours ? 'H' : '';
    if (stat.data.isNotEmpty){
      final bmi = _getBmiLabel(stat.data.first);
      bmiText = bmi.key;  
      bmiColor = bmi.value;
    } else {
      bmiColor = Colors.grey;
      bmiText = 'Não Calculado';

    }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: const Color.fromARGB(7, 0, 0, 0), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(stat.icon, color: stat.color),
          SizedBox(width: 12),
          Text("${stat.title}",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        SizedBox(height: 20),
        const SizedBox(height: 12),
        if (stat.isBmi && selectedPeriod == 'day') ...[ 
          SizedBox(width: 300, height: 200,
          child: 
          InkWell(
            onTap: () {
        _showBmiDialog();
            },
            child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: 
            stat.data.isEmpty || stat.data.last == 0.0? 
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
      Stack(alignment: Alignment.center,
      children: [
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
                        ? (stat.data.first >= stat.goal ? 1.0 : (stat.data.first / stat.goal))
                        : 0.0,
                        color: stat.color,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: stat.data.isNotEmpty
                            ? (1 - (stat.data.first / stat.goal)).clamp(0.0, 1.0)
                            : 1.0,
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4),
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
                                  style:  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4), fontSize: 11));
                            }

                            final displayValue = stat.isPercentage
                                ? (value * 100).toInt().toString()
                                : value.toStringAsFixed(1);

                            return Text("$displayValue ${stat.unit}",
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4), fontSize: 11));
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
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4), fontSize: 12));
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
        if (selectedPeriod == 'day' && stat.goal > 0)
        if (stat.title == 'Dias Ativos')
        Text(
        '${stat.data.first == stat.goal? "Ativo" : "Inativo"}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      if (stat.title != 'Dias Ativos')
      Text(
        '${valorAtual.toStringAsFixed(1)} $unidade / ${valorMeta.toStringAsFixed(0)} $unidade',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      )
    ]),
        ]
        ],
  ),
  );
}
}
