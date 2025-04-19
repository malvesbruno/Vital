import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/ExercicioModel.dart';
import 'models/TreinoModel.dart';
import 'models/QuickAction.dart';
import 'models/DailyChallenge.dart';
import 'models/StatsModel.dart';
import 'models/AtividadeModel.dart';
import 'services/Notication.dart';
import 'services/challenge_service.dart';
import 'models/DailyStatsModel.dart';

class AppData {
  static List<TreinoModel> treinos = [];
  static List<ExercicioModel> treinosSelecionados = [];
  static List<QuickAction> quickActions = [];
  static List<AtividadeModel> listaAtividades = [];
  static List<DailyStats> dailyStats = [];
  static List<String> categorias = [
    'Estudo', 'Trabalho', 'Treino', 'Saúde', 'Lazer', 'Social', 'Rotina', 'Outro'
  ];
  static DateTime ultimaDataSalva = DateTime.now();
  static List<DailyStats> historicoStats = [];

  static Future<void> verificarSePrecisaSalvarHoje() async {
  final hoje = DateTime.now();
  if (!ehMesmoDia(ultimaDataSalva, hoje)) {
    await salvarStatsDoDia();
    resetarDadosDoDia();
    ultimaDataSalva = hoje;
    await salvarDados();
  }
}

static bool ehMesmoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

static Future<void> salvarStatsDoDia() async {
  final stats = DailyStats(
    date: ultimaDataSalva,
    waterLiters: waterConsumed.toDouble(),
    completedActivities: completedActivities,
    completedWorkouts: treinosDiarios,
    wasActive: true,
  );

  historicoStats.add(stats);
}

static void resetarDadosDoDia() {
  waterConsumed = 0;
  completedActivities = 0;
  treinosDiarios = 0;
  ativoHoje = false;
}

  void verificarEAgendarNotificacoes() {

    DateTime _timeOfDayToDateTime(TimeOfDay time) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }
  



  final agora = DateTime.now();

  for (var treino in treinos) {
    final horarioTreino = _timeOfDayToDateTime(treino.horario);

    // Notificar se estiver dentro dos próximos 5 minutos
    if (horarioTreino.difference(agora).inMinutes >= 0 &&
        horarioTreino.difference(agora).inMinutes <= 5) {
      NotificationService().agendarNotificacao(
        id: NotificationService.gerarId(),
        titulo: 'Hora do treino!',
        corpo: '${treino.nome} está prestes a começar!',
        horario: horarioTreino,
      );
    }
  }

  for (var atividade in listaAtividades) {
    final horarioAtividade = _timeOfDayToDateTime(atividade.horario);
    

    if (horarioAtividade.difference(agora).inMinutes >= 0 &&
        horarioAtividade.difference(agora).inMinutes <= 5) {
      NotificationService().agendarNotificacao(
        id: NotificationService.gerarId(),
        titulo: 'Atividade importante',
        corpo: '${atividade.title} está chegando!',
        horario: horarioAtividade
      );
    }
  }
}


  static List<DailyChallengeModel> dailyChallenges = [];

static Future<void> carregarDesafiosDoDia() async {
  await ChallengeService.inicializarDesafios();
  dailyChallenges = await ChallengeService.carregarDesafiosDoDia();
}

  static int waterConsumed = 0;
  static int coins = 0;
  static int exp = 0;
  static int level = 0;
  static int treinosDiarios = 0;
  static int completedActivities = 0;
  static double progress = 0.0;
  static double horasDormidas = 0;
  static List<double> lista = [10, 8, 9, 10, 4, 0, 10];
  static bool ativoHoje = false;

  static void addExperience(int xp) {
    print("[DEBUG] Adding EXP: $xp | Current EXP: $exp | Level: $level"); // ✅ Debug
    exp += xp;

    int xpNeeded = 100 + (level - 1) * 50;
    while (exp >= xpNeeded) {
      exp -= xpNeeded;
      level++;
      xpNeeded = 100 + (level - 1) * 50;
      print("[DEBUG] Level Up! New Level: $level | EXP Left: $exp"); // ✅ Debug
    }
}



  

  static List<StatsModel> getStatsOfLastDays(int n) {
  final List<DailyStats> ultimosDias = dailyStats
    .where((s) => s.date.isAfter(DateTime.now().subtract(Duration(days: n))))
    .toList();

  bool isHojeNaLista(List<int> diasDaSemana) {
  int weekday = DateTime.now().weekday;
  return diasDaSemana.contains(weekday);
}

  return [
    StatsModel(
      date: DateTime.now(),
      title: "Consumo de Água",
      unit: "L",
      icon: Icons.water_drop,
      color: Colors.blueAccent,
      isPercentage: false,
      labels: ultimosDias.map((e) => "${e.date.day}/${e.date.month}").toList(),
      data: ultimosDias.map((e) => e.waterLiters.toDouble()).toList(),
      goal: 2
    ),
    StatsModel(
      date: DateTime.now(),
      title: "Atividades Concluídas",
      unit: "✓",
      icon: Icons.check_circle,
      color: Colors.greenAccent,
      isPercentage: false,
      labels: ultimosDias.map((e) => "${e.date.day}/${e.date.month}").toList(),
      data: ultimosDias.map((e) => e.completedActivities.toDouble()).toList(),
      goal: AppData.listaAtividades.where((el) => isHojeNaLista(el.dias)).length.toDouble()
    ),
    StatsModel(
      date: DateTime.now(),
      title: "Treinos Concluídos",
      unit: "✓",
      icon: Icons.fitness_center,
      color: Colors.orange,
      isPercentage: false,
      labels: ultimosDias.map((e) => "${e.date.day}/${e.date.month}").toList(),
      data: ultimosDias.map((e) => e.completedWorkouts.toDouble()).toList(),
      goal: AppData.listaAtividades.where((el) => isHojeNaLista(el.dias)).length.toDouble()
    ),
    StatsModel(
      date: DateTime.now(),
      title: "Dias Ativos",
      unit: "",
      icon: Icons.local_fire_department,
      color: Colors.redAccent,
      isPercentage: true,
      labels: ultimosDias.map((e) => "${e.date.day}/${e.date.month}").toList(),
      data: ultimosDias.map((e) => e.wasActive ? 1.0 : 0.0).toList(),
      goal: 1.0
    ),
  ];
}




  // Retorna os exercícios do dia atual
  static List<ExercicioModel> getExerciciosDoDia() {
    final hoje = DateTime.now().weekday;
    return treinos
        .where((t) => t.diasSemana.contains(hoje))
        .expand((t) => t.exercicios)
        .where((e) => e.completed != true)
        .toList();
  }

  static List<TreinoModel> getTreinosNome() {
    final hoje = DateTime.now().weekday;
    return treinos.where((test) => test.diasSemana.contains(hoje)).toList();
  }


  static void atualizarDailyStats({
  double? agua,
  bool atividadeConcluida = false,
  bool treinoConcluido = false,
}) {
  final hoje = DateTime.now();
  final hojeFormatado = DateTime(hoje.year, hoje.month, hoje.day);

  // Busca o stats de hoje
  DailyStats? statsHoje = dailyStats.firstWhere(
    (s) => DateTime(s.date.year, s.date.month, s.date.day) == hojeFormatado,
    orElse: () => DailyStats(date: hojeFormatado),
  );

  // Se não estava na lista, adiciona
  if (!dailyStats.contains(statsHoje)) {
    dailyStats.add(statsHoje);
  }

  // Atualiza os dados
  statsHoje = DailyStats(
    date: statsHoje.date,
    waterLiters: statsHoje.waterLiters + (agua ?? 0.0),
    completedActivities: statsHoje.completedActivities + (atividadeConcluida ? 1 : 0),
    completedWorkouts: statsHoje.completedWorkouts + (treinoConcluido ? 1 : 0),
    wasActive: true,
  );

  // Substitui o antigo
  dailyStats.removeWhere((s) => DateTime(s.date.year, s.date.month, s.date.day) == hojeFormatado);
  dailyStats.add(statsHoje);

  salvarDailyStats(); // Persiste
}

static void salvarDailyStats() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = dailyStats.map((e) => jsonEncode(e.toJson())).toList();
  prefs.setStringList('stats', jsonList);
}


  // ========= SALVAR DADOS =========
  static Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setStringList('treinos', treinos.map((t) => jsonEncode(t.toJson())).toList());
    prefs.setStringList('treinosSelecionados', treinosSelecionados.map((e) => jsonEncode(e.toJson())).toList());
    prefs.setStringList('quickActions', quickActions.map((a) => jsonEncode(a.toJson())).toList());
    prefs.setStringList('listaAtividades', listaAtividades.map((a) => jsonEncode(a)).toList());
    prefs.setStringList('stats', dailyStats.map((s) => jsonEncode(s.toJson())).toList());
    prefs.setString('ultimaDataSalva', ultimaDataSalva.toIso8601String());
    prefs.setString('historicoStats', jsonEncode(historicoStats.map((e) => e.toJson()).toList()));
    prefs.setInt('coins', coins);
    prefs.setInt('exp', exp);
    prefs.setInt('level', level);

    prefs.setInt('waterConsumed', waterConsumed);
    prefs.setInt('treinosDiarios', treinosDiarios);
    prefs.setInt('completedActivities', completedActivities);
    prefs.setDouble('progress', progress);
    prefs.setDouble('horasDormidas', horasDormidas);
  }

  static DateTime _parseDateSafely(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) {
    return DateTime.now(); // ou qualquer valor padrão que você queira
  }
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    print("Erro ao converter data: $dateStr");
    return DateTime.now(); // ou lança uma exceção se preferir
  }
}

  // ========= CARREGAR DADOS =========
  static Future<void> carregarDados() async {
  final prefs = await SharedPreferences.getInstance();

  final treinosJson = prefs.getStringList('treinos');
  if (treinosJson != null) {
    treinos = treinosJson.map((jsonStr) => TreinoModel.fromJson(jsonDecode(jsonStr))).toList();
  }

  final selecionadosJson = prefs.getStringList('treinosSelecionados');
  if (selecionadosJson != null) {
    treinosSelecionados = selecionadosJson.map((jsonStr) => ExercicioModel.fromJson(jsonDecode(jsonStr))).toList();
  }

  final actionsJson = prefs.getStringList('quickActions');
  if (actionsJson != null) {
    quickActions = actionsJson.map((jsonStr) => QuickAction.fromJson(jsonDecode(jsonStr))).toList();
  }

  final atividadesJson = prefs.getStringList('listaAtividades');
  if (atividadesJson != null) {
    listaAtividades = atividadesJson.map((jsonStr) => AtividadeModel.fromJson(jsonDecode(jsonStr))).toList();
  }

  final statsJson = prefs.getStringList('stats');
  if (statsJson != null) {
    dailyStats = statsJson.map((jsonStr) => DailyStats.fromJson(jsonDecode(jsonStr))).toList();
  }

  final dataString = prefs.getString('ultimaDataSalva');
  if (dataString != null) {
  try {
    ultimaDataSalva = _parseDateSafely(dataString);  // Tenta fazer o parse da string para DateTime
  } catch (e) {
    // Se o formato for inválido, podemos definir uma data padrão
    ultimaDataSalva = DateTime.now();  // Defina como a data atual em caso de erro
  }
}


  final historicoString = prefs.getString('historicoStats');
  if (historicoString != null) {
    final List<dynamic> listaJson = jsonDecode(historicoString);
    historicoStats = listaJson.map((e) => DailyStats.fromJson(e)).toList();
  }

  waterConsumed = prefs.getInt('waterConsumed') ?? 0;
  treinosDiarios = prefs.getInt('treinosDiarios') ?? 0;
  coins = prefs.getInt('coins') ?? 0;
  exp = prefs.getInt('exp') ?? 0;
  level = prefs.getInt('level') ?? 0;
  completedActivities = prefs.getInt('completedActivities') ?? 0;
  progress = prefs.getDouble('progress') ?? 0.0;
  horasDormidas = prefs.getDouble('horasDormidas') ?? 0.0;
}

  // ========= OPCIONAL: RESET =========
  static Future<void> limparDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
