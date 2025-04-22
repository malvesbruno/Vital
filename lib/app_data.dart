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
import 'models/AvatarModel.dart';
import '../pages/LevelUpPage.dart';

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
    bmi: bmi
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
  static int level = 1;
  static String currentAvatar = avatars[0].name;
  static int treinosDiarios = 0;
  static double bmi = 0.0;
  static int completedActivities = 0;
  static double progress = 0.0;
  static double horasDormidas = 0;
  static List<double> lista = [10, 8, 9, 10, 4, 0, 10];
  static bool ativoHoje = false;

  static void addExperience(BuildContext context, int xp) {
    print("[DEBUG] Adding EXP: $xp | Current EXP: $exp | Level: $level"); // ✅ Debug
    exp += xp;

    int xpNeeded = 100 + (level - 1) * 50;
    while (exp >= xpNeeded) {
      exp -= xpNeeded;
      level++;
      xpNeeded = 100 + (level - 1) * 50;
      print("[DEBUG] Level Up! New Level: $level | EXP Left: $exp"); // ✅ Debug
      AvatarModel? avatar = avatars.firstWhere((el) => el.requiredLevel == level, orElse: () => AvatarModel(name: 'Desconhecido', imagePath: '', requiredLevel: 0, price: 0,));
      late List<String> lista_levelUp;
      if (avatar.name != 'Desconhecido'){
        lista_levelUp = [avatar.name, avatar.imagePath];
      } else{
        lista_levelUp = [];
      }
      salvarDados();

      Navigator.push(context, MaterialPageRoute(builder: (context) => LevelUpPage(newLevel: level, unlockedItems: lista_levelUp)));
    }
}

  static Future<void> saveOwnedAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    final ownedNames = avatars
        .where((avatar) => avatar.owned)
        .map((avatar) => avatar.name)
        .toList();
    await prefs.setStringList('Owned Avatars', ownedNames);
  }

  static Future<void> loadOwnedAvatars() async {
  final prefs = await SharedPreferences.getInstance();
  final ownedNames = prefs.getStringList('Owned Avatars') ?? [];

  for (var avatar in avatars) {
    if (avatar.name == 'Default'){
      avatar.owned = true;
    } else{
    avatar.owned = ownedNames.contains(avatar.name);
    }
  }
}


  static List<AvatarModel> avatars = [
    AvatarModel(name: 'Default', imagePath: 'assets/avatares/default.png', price: 0, requiredLevel: 1, owned: true),
    AvatarModel(name: 'Nerd', imagePath: 'assets/avatares/nerd.png', price: 100, requiredLevel: 3),
    AvatarModel(name: 'Hippie', imagePath: 'assets/avatares/hippie.png', price: 120, requiredLevel: 5),
    AvatarModel(name: 'Girl', imagePath: 'assets/avatares/girl.png', price: 140, requiredLevel: 8),
    AvatarModel(name: 'Rocker', imagePath: 'assets/avatares/rocker.png', price: 160, requiredLevel: 10),
    AvatarModel(name: 'Boho', imagePath: 'assets/avatares/boho.png', price: 180, requiredLevel: 12),
    AvatarModel(name: 'Atleta', imagePath: 'assets/avatares/atleta.png', price: 200, requiredLevel: 14),
    AvatarModel(name: 'Mago', imagePath: 'assets/avatares/mago.png', price: 220, requiredLevel: 18),
    AvatarModel(name: 'Street', imagePath: 'assets/avatares/street.png', price: 240, requiredLevel: 20),
    AvatarModel(name: 'Robô', imagePath: 'assets/avatares/robo.png', price: 260, requiredLevel: 25),
    AvatarModel(name: 'Musicman', imagePath: 'assets/avatares/musicman.png', price: 280, requiredLevel: 30),
    AvatarModel(name: 'Rocketman', imagePath: 'assets/avatares/rocketman.png', price: 300, requiredLevel: 40),
    AvatarModel(name: 'Dex', imagePath: 'assets/avatares/dex.png', price: 350, requiredLevel: 50),
  ];


  static void buyAvatar(String name) async{
    final avatar = avatars.firstWhere((a) => a.name == name);
    if (!avatar.owned && coins >= avatar.price && level >= avatar.requiredLevel) {
      coins -= avatar.price;
      avatar.owned = true;
      await saveOwnedAvatars();
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
      goal: 2000,
      isBmi: false
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
      goal: AppData.listaAtividades.where((el) => isHojeNaLista(el.dias)).length.toDouble(),
      isBmi: false
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
      goal: AppData.listaAtividades.where((el) => isHojeNaLista(el.dias)).length.toDouble(),
      isBmi: false
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
      goal: 1.0,
      isBmi: false
    ),
    StatsModel(
      date: DateTime.now(),
      title: "IMC Atual",
      unit: "",
      icon: Icons.monitor_weight,
      color: Colors.purple,
      isPercentage: true,
      labels: ultimosDias.map((e) => "${e.date.day}/${e.date.month}").toList(),
      data: ultimosDias.map((e) => e.bmi.toDouble()).toList(),
      goal: 0.0,
      isBmi: true
    ),
  ];
}


static void setBmi(double bmiImput){
  bmi = bmiImput;
  atualizarDailyStats(bmi: bmiImput);
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
  double bmi = 0.0,
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
    bmi: bmi,
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
    prefs.setString('currentAvatar', currentAvatar);
    prefs.setStringList('desafios_do_dia', dailyChallenges.map((d) => jsonEncode(d.toJson())).toList());

    prefs.setInt('waterConsumed', waterConsumed);
    prefs.setInt('treinosDiarios', treinosDiarios);
    prefs.setInt('completedActivities', completedActivities);
    prefs.setDouble('progress', progress);
    prefs.setDouble('bmi', bmi);
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
  final challengesJson = prefs.getStringList('desafios_do_dia');
  if (challengesJson != null){
    dailyChallenges = challengesJson.map((jsonStr) => DailyChallengeModel.fromJson(jsonDecode(jsonStr))).toList();
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
  coins = prefs.getInt('coins') ?? 2000;
  exp = prefs.getInt('exp') ?? 190;
  level = prefs.getInt('level') ?? 2;
  bmi = prefs.getDouble('bmi') ?? 0.0;
  currentAvatar = prefs.getString('currentAvatar') ?? 'Default';
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
