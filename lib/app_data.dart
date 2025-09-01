import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital/app_data_service.dart';
import 'package:vital/services/reset_daily.dart';

import 'models/ExercicioModel.dart';
import 'models/TreinoModel.dart';
import 'models/QuickAction.dart';
import 'models/DailyChallenge.dart';
import 'models/StatsModel.dart';
import 'models/AtividadeModel.dart';
import 'services/challenge_service.dart';
import 'models/DailyStatsModel.dart';
import 'models/AvatarModel.dart';
import '../pages/LevelUpPage.dart';
import '../models/ColorsModel.dart';
import '../models/AmigoModel.dart';
import 'package:uuid/uuid.dart';


class AppData {
  // inicia os dados
  static List<TreinoModel> treinos = [];
  static List<ExercicioModel> treinosSelecionados = [];
  static List<QuickAction> quickActions = [];
  static List<AtividadeModel> listaAtividades = [];
  static List<DailyStats> dailyStats = [];
  static List<String> categorias = [
    'Estudo', 'Trabalho', 'Saúde', 'Lazer', 'Social', 'Rotina', 'Outro'
  ];
  static DateTime ultimaDataSalva = DateTime.now();
  static List<DailyStats> historicoStats = [];

  // verifica se precisa salvar hoje
  static Future<void> verificarSePrecisaSalvarHoje() async {
  final hoje = DateTime.now();
  if (!ehMesmoDia(ultimaDataSalva, hoje)) {
    await salvarStatsDoDia();
    DailyResetService.verificarEDefinirNovoDia();
    resetarDadosDoDia();
    ultimaDataSalva = hoje;
    await AppDataService.salvarTudo();
  }
}

static bool ehMesmoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// salvar os status do dia
static Future<void> salvarStatsDoDia() async {
  final stats = DailyStats(
    date: ultimaDataSalva,
    waterLiters: waterConsumed.toDouble(),
    completedActivities: completedActivities,
    completedWorkouts: treinosDiarios,
    horasDormidas: horasDormidas,
    wasActive: true,
    bmi: bmi
  );

  historicoStats.add(stats);
}

// resetar os dados do dia
static void resetarDadosDoDia() {
  waterConsumed = 0;
  completedActivities = 0;
  treinosDiarios = 0;
  ativoHoje = false;
}

  static List<DailyChallengeModel> dailyChallenges = [];

// carrega os desafios do dia
static Future<void> carregarDesafiosDoDia() async {
  await ChallengeService.inicializarDesafios();
  dailyChallenges = await ChallengeService.carregarDesafiosDoDia();
}

  static int waterConsumed = 0;
  static bool ultimate = false;
  static String name = 'Deafult_Name';
  static int coins = 0;
  static int exp = 0;
  static int level = 1;
  static String currentAvatar = avatars[0].name;
  static String currentTheme = themes[0].name;
  static bool isExclusiveTheme = false;
  static int treinosDiarios = 0;
  static double bmi = 0.0;
  static int multiplicador = 1;
  static int steps = 0;

  var uuid = Uuid();
  static String id = Uuid().v4();

  static List<AmigoModel> amigos = [
  ];
  static int completedActivities = 0;
  static double progress = 0.0;
  static double horasDormidas = 0;
  static List<double> lista = [10, 8, 9, 10, 4, 0, 10];
  static bool ativoHoje = false;

// adiciona experiência 
  static void addExperience(BuildContext context, int xp) {
    exp += xp * multiplicador;

    int xpNeeded = 100 + (level - 1) * 50;
    while (exp >= xpNeeded) {
      exp -= xpNeeded;
      level++;
      xpNeeded = 100 + (level - 1) * 50;
      AvatarModel? avatar = avatars.firstWhere((el) => el.requiredLevel == level, orElse: () => AvatarModel(name: 'Desconhecido', imagePath: '', requiredLevel: 0, price: 0, exclusive: false));
      late List<String> lista_levelUp;
      if (avatar.name != 'Desconhecido'){
        lista_levelUp = [avatar.name, avatar.imagePath];
      } else{
        lista_levelUp = [];
      }
      AppDataService.salvarTudo();

      Navigator.push(context, MaterialPageRoute(builder: (context) => LevelUpPage(newLevel: level, unlockedItems: lista_levelUp)));
    }
}

  // salva avatares comprados
  static Future<void> saveOwnedAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    final ownedNames = avatars
        .where((avatar) => avatar.owned)
        .map((avatar) => avatar.name)
        .toList();
    await prefs.setStringList('Owned Avatars', ownedNames);
  }

  // salva temas comprados
  static Future<void> saveOwnedColors() async {
    final prefs = await SharedPreferences.getInstance();
    final ownedColorNames = themes
        .where((color) => color.owned)
        .map((color) => color.name)
        .toList();
    await prefs.setStringList('Owned Colors', ownedColorNames);
  }

  // carrega avatares comprados
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

// carrega temas comprados
static Future<void> loadOwnedColors() async {
  final prefs = await SharedPreferences.getInstance();
  final ownedNames = prefs.getStringList('Owned Colors') ?? [];

  for (var color in themes) {
    if (color.name == 'Default'){
      color.owned = true;
    } else{
    color.owned = ownedNames.contains(color.name);
    }
  }
}

  // lista de avatares
  static List<AvatarModel> avatars = [
  AvatarModel(name: 'Default', imagePath: 'assets/avatares/default.png', price: 0, requiredLevel: 1, owned: true, exclusive: false),
  AvatarModel(name: 'Nerd', imagePath: 'assets/avatares/nerd.png', price: 30, requiredLevel: 3, exclusive: false),
  AvatarModel(name: 'Sad Saddler', imagePath: 'assets/avatares/sad_saddler.png', price: 50, requiredLevel: 5, exclusive: true),
  AvatarModel(name: 'Hippie', imagePath: 'assets/avatares/hippie.png', price: 80, requiredLevel: 8, exclusive: false),
  AvatarModel(name: 'Tacitus Kilgore', imagePath: 'assets/avatares/tacitus.png', price: 100, requiredLevel: 10, exclusive: true),
  AvatarModel(name: 'Andorinha', imagePath: 'assets/avatares/andorinha.png', price: 150, requiredLevel: 15, exclusive: true),
  AvatarModel(name: 'Girl', imagePath: 'assets/avatares/girl.png', price: 200, requiredLevel: 20, exclusive: false),
  AvatarModel(name: 'Carniceiro', imagePath: 'assets/avatares/carniceiro.png', price: 270, requiredLevel: 27, exclusive: true),
  AvatarModel(name: 'Cicatriz', imagePath: 'assets/avatares/cicatriz.png', price: 350, requiredLevel: 35, exclusive: true),
  AvatarModel(name: 'Feiticeira Nata', imagePath: 'assets/avatares/feiticeira_nata.png', price: 420, requiredLevel: 42, exclusive: true),
  AvatarModel(name: 'Atleta', imagePath: 'assets/avatares/atleta.png', price: 500, requiredLevel: 50, exclusive: false),
  AvatarModel(name: 'Fantasma De VitalCity', imagePath: 'assets/avatares/ghost.png', price: 580, requiredLevel: 58, exclusive: true),
  AvatarModel(name: 'Rocker', imagePath: 'assets/avatares/rocker.png', price: 630, requiredLevel: 63, exclusive: false),
  AvatarModel(name: 'Boho', imagePath: 'assets/avatares/boho.png', price: 700, requiredLevel: 70, exclusive: false),
  AvatarModel(name: 'King of Pirates', imagePath: 'assets/avatares/king_of_pirates.png', price: 750, requiredLevel: 75, exclusive: true),
  AvatarModel(name: 'Mago', imagePath: 'assets/avatares/mago.png', price: 800, requiredLevel: 80, exclusive: false),
  AvatarModel(name: 'Lightblade', imagePath: 'assets/avatares/lightblade.png', price: 870, requiredLevel: 87, exclusive: true),
  AvatarModel(name: 'Street', imagePath: 'assets/avatares/street.png', price: 900, requiredLevel: 90, exclusive: false),
  AvatarModel(name: 'Princesa Rebelde', imagePath: 'assets/avatares/princesa_rebelde.png', price: 950, requiredLevel: 95, exclusive: true),
  AvatarModel(name: 'Mr. Vega', imagePath: 'assets/avatares/mr_vega.png', price: 1000, requiredLevel: 100, exclusive: true),
  AvatarModel(name: 'Vinil & Veneno', imagePath: 'assets/avatares/vinil_veneno.png', price: 1100, requiredLevel: 110, exclusive: true),
  AvatarModel(name: 'Original de VitalWell', imagePath: 'assets/avatares/original.png', price: 1200, requiredLevel: 120, exclusive: true),
  AvatarModel(name: 'Caos', imagePath: 'assets/avatares/caos.png', price: 1300, requiredLevel: 130, exclusive: true),
  AvatarModel(name: 'Rocketman', imagePath: 'assets/avatares/rocketman.png', price: 1350, requiredLevel: 135, exclusive: false),
  AvatarModel(name: 'Broken One', imagePath: 'assets/avatares/broken_one.png', price: 1400, requiredLevel: 140, exclusive: true),
  AvatarModel(name: 'Red Rebellion', imagePath: 'assets/avatares/red_rebellion.png', price: 1500, requiredLevel: 150, exclusive: true),
  AvatarModel(name: 'Negative Creep', imagePath: 'assets/avatares/negative_creep.png', price: 1600, requiredLevel: 160, exclusive: true),
  AvatarModel(name: 'BetterMan', imagePath: 'assets/avatares/betterman.png', price: 1700, requiredLevel: 170, exclusive: true),
  AvatarModel(name: 'Ele já não apareceu?', imagePath: 'assets/avatares/narrator.png', price: 1750, requiredLevel: 175, exclusive: true),
  AvatarModel(name: 'Parceiro da Vizinhança', imagePath: 'assets/avatares/spider.png', price: 1800, requiredLevel: 180, exclusive: true),
  AvatarModel(name: 'Dex', imagePath: 'assets/avatares/dex.png', price: 1850, requiredLevel: 185,exclusive: false),
  AvatarModel(name: 'Robô', imagePath: 'assets/avatares/robo.png', price: 2000, requiredLevel: 200, exclusive: false),
];
  // lista de cores
  static List<AppTheme> themes = [
  // Sempre começa com o padrão
  AppTheme(
    name: 'Default',
    backgroundColor: Colors.black,
    primaryColor: Color(0xFF1F1F1F),
    secondaryColor: Color(0xFF9E9E9E),
    accentColor: Color(0xFFFFC107),
    textColor: Colors.white,
    imagePath: 'assets/colors/defaultColor.png',
    price: 0,
    requiredLevel: 1,
    owned: true,
    exclusive: false,
  ),
  
  // Início misturado
  AppTheme(
    name: "Ciano Escuro",
    backgroundColor: Color(0xFF1E1E1E),
    primaryColor: Color.fromARGB(255, 42, 81, 81),
    secondaryColor: Color(0xFF4FBDBD),
    textColor: Colors.white,
    accentColor: Color(0xFF00FFFF),
    imagePath: 'assets/colors/ciano_escuro.png',
    price: 90,
    requiredLevel: 2,
    exclusive: false,
  ),
  AppTheme(
    name: "Stage",
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    primaryColor: Color.fromARGB(255, 21, 21, 21),
    secondaryColor: Color.fromARGB(255, 255, 255, 255),
    textColor: Colors.white,
    accentColor: Color.fromARGB(255, 114, 114, 114),
    imagePath: 'assets/colors/themes/pj.png',
    price: 130,
    requiredLevel: 5,
    exclusive: true,
  ),
  AppTheme(
    name: "Grafite & Neve",
    backgroundColor: Color(0xFF2B2B2B),
    primaryColor: Color.fromARGB(255, 116, 116, 116),
    secondaryColor: Color(0xFFDADADA),
    textColor: Colors.white,
    accentColor: Color(0xFF4A90E2),
    imagePath: 'assets/colors/grafite_&_neve.png',
    price: 150,
    requiredLevel: 7,
    exclusive: false,
  ),
  AppTheme(
    name: "VitalCity",
    backgroundColor: Color.fromARGB(255, 12, 22, 39),
    primaryColor: Color(0xFF3A6199),
    secondaryColor: Color(0xFF4A7FB8),
    textColor: Colors.white,
    accentColor: Color(0xFFABDEF1),
    imagePath: 'assets/colors/themes/ny.png',
    price: 180,
    requiredLevel: 10,
    exclusive: true,
  ),
  AppTheme(
    name: "Noite Azulada",
    backgroundColor: Color(0xFF0D1B2A),
    primaryColor: Color.fromARGB(255, 90, 92, 102),
    secondaryColor: Color(0xFF415A77),
    textColor: Colors.white,
    accentColor: Color(0xFF00BFFF),
    imagePath: 'assets/colors/noite_azulada.png',
    price: 200,
    requiredLevel: 12,
    exclusive: false,
  ),
  AppTheme(
    name: "Apocalypse",
    backgroundColor: Color(0xFF06070A),
    primaryColor: Color(0xFF565B60),
    secondaryColor: Color(0xFF405E56),
    textColor: Colors.white,
    accentColor: Color.fromARGB(255, 192, 219, 160),
    imagePath: 'assets/colors/themes/dg.png',
    price: 220,
    requiredLevel: 15,
    exclusive: true,
  ),
  AppTheme(
    name: "Espaço & Azul",
    backgroundColor: Color(0xFF202124),
    primaryColor: Color(0xFF3F88C5),
    secondaryColor: Color(0xFF72AEE6),
    textColor: Colors.white,
    accentColor: Color(0xFF64FFDA),
    imagePath: 'assets/colors/espaço_&_azul.png',
    price: 240,
    requiredLevel: 17,
    exclusive: false,
  ),
  AppTheme(
    name: "Japan",
    backgroundColor: Color.fromARGB(255, 6, 13, 14),
    primaryColor: Color(0xFF9A0133),
    secondaryColor: Color(0xFFB22222),
    textColor: Colors.white,
    accentColor: Color(0xFFFBB96A),
    imagePath: 'assets/colors/themes/japan.png',
    price: 260,
    requiredLevel: 20,
    exclusive: true,
  ),
  AppTheme(
    name: '"Seu apartamento explodiu?"',
    backgroundColor: Color.fromARGB(255, 4, 7, 12),
    primaryColor: Color(0xFF132032),
    secondaryColor: Color(0xFF172B40),
    textColor: Colors.white,
    accentColor: Color(0xFF41576D),
    imagePath: 'assets/colors/themes/fc.png',
    price: 290,
    requiredLevel: 24,
    exclusive: true,
  ),
  AppTheme(
    name: "Big Kanuha",
    backgroundColor: Color(0xFF14152B),
    primaryColor: Color(0xFF414C68),
    secondaryColor: Color(0xFF75818D),
    textColor: Colors.white,
    accentColor: Color(0xFFF82A44),
    imagePath: 'assets/colors/themes/pf.png',
    price: 310,
    requiredLevel: 27,
    exclusive: true,
  ),
  AppTheme(
    name: "Vermelho Profundo",
    backgroundColor: Color(0xFF121212),
    primaryColor: Color(0xFF8B0000),
    secondaryColor: Color(0xFFB22222),
    textColor: Colors.white,
    accentColor: Color(0xFFFF4500),
    imagePath: 'assets/colors/vermelho_profundo.png',
    price: 330,
    requiredLevel: 30,
    exclusive: false,
  ),

  // Parte final: GRANDES temas
  AppTheme(
    name: "Faroeste",
    backgroundColor: Color.fromARGB(255, 12, 6, 7),
    primaryColor: Color(0xFF762017),
    secondaryColor: Color(0xFFE05210),
    textColor: Colors.white,
    accentColor: Color(0xFFF8CD52),
    imagePath: 'assets/colors/themes/faroeste.png',
    price: 450,
    requiredLevel: 50,
    exclusive: true,
  ),
  AppTheme(
    name: "Space",
    backgroundColor: Color(0xFF010C27),
    primaryColor: Color(0xFF352F6B),
    secondaryColor: Color(0xFFE09A70),
    textColor: Colors.white,
    accentColor: Color(0xFFFF4500),
    imagePath: 'assets/colors/themes/space.png',
    price: 470,
    requiredLevel: 53,
    exclusive: true,
  ),
  AppTheme(
    name: "Temple",
    backgroundColor: Color.fromARGB(255, 9, 19, 20),
    primaryColor: Color(0xFF265138),
    secondaryColor: Color(0xFF7E9C47),
    textColor: Colors.white,
    accentColor: Color(0xFF779F32),
    imagePath: 'assets/colors/themes/temple.png',
    price: 480,
    requiredLevel: 55,
    exclusive: true,
  ),
  AppTheme(
    name: "City",
    backgroundColor: Color(0xFF03061D),
    primaryColor: Color(0xFF021F56),
    secondaryColor: Color(0xFF033369),
    textColor: Colors.white,
    accentColor: Color(0xFFB1357E),
    imagePath: 'assets/colors/themes/city.png',
    price: 490,
    requiredLevel: 57,
    exclusive: true,
  ),
  AppTheme(
    name: "Sea",
    backgroundColor: Color(0xFF164260),
    primaryColor: Color(0xFF2D7684),
    secondaryColor: Color(0xFFA6CFBA),
    textColor: Colors.white,
    accentColor: Color(0xFFA6CFBA),
    imagePath: 'assets/colors/themes/sea.png',
    price: 500,
    requiredLevel: 60,
    exclusive: true,
  ),
  AppTheme(
    name: "Fire",
    backgroundColor: Color.fromARGB(255, 1, 5, 10),
    primaryColor: Color(0xFF8B0000),
    secondaryColor: Color(0xFFB22222),
    textColor: Colors.white,
    accentColor: Color(0xFFFF4500),
    imagePath: 'assets/colors/themes/fire.png',
    price: 520,
    requiredLevel: 65,
    exclusive: true,
  ),
];


  // comprar avatar
  static void buyAvatar(String name) async{
    final avatar = avatars.firstWhere((a) => a.name == name);
    if (!avatar.owned && coins >= avatar.price && level >= avatar.requiredLevel) {
      coins -= avatar.price;
      avatar.owned = true;
      await saveOwnedAvatars();
    }
  }
  // comprar cores
  static void buyColor(String name) async{
    final color = themes.firstWhere((a) => a.name == name);
    if (!color.owned && coins >= color.price && level >= color.requiredLevel) {
      coins -= color.price;
      color.owned = true;
      await saveOwnedColors();
    }
  }
  
  // pega stats dos útimos dias
  static List<StatsModel> getStatsOfLastDays(int n) {
  final today = DateTime.now();
  final startDate = DateTime(today.year, today.month, today.day).subtract(Duration(days: n - 1));

  bool isHojeNaLista(List<int> diasDaSemana) {
    int weekday = today.weekday;
    return diasDaSemana.contains(weekday);
  }

  if (n > 1){

  final List<DailyStats> ultimosDias = historicoStats
    .where((s) {
      final dataSemHora = DateTime(s.date.year, s.date.month, s.date.day);
      return dataSemHora.isAfter(startDate.subtract(const Duration(days: 1))) &&
             dataSemHora.isBefore(today.add(const Duration(days: 1)));
    })
    .toList()
    ..sort((a, b) => a.date.compareTo(b.date)); // ordenar para os gráficos ficarem certos

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
      goal: AppData.treinos.where((el) => isHojeNaLista(el.diasSemana)).length.toDouble(),
      isBmi: false
    ),
    StatsModel(
      date: DateTime.now(),
      title: "Horas Dormidas",
      unit: "H",
      icon: Icons.bed,
      color: const Color.fromARGB(255, 166, 187, 255),
      isPercentage: false,
      labels: ultimosDias.map((e) => "${e.date.day}/${e.date.month}").toList(),
      data: ultimosDias.map((e) => e.horasDormidas.toDouble()).toList(),
      goal: 8,
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
  } else {
    DailyStats hj = DailyStats(date: DateTime.now(), waterLiters: waterConsumed.toDouble(), completedActivities: completedActivities, completedWorkouts: treinos.expand((treino) => treino.exercicios).where(((ex) => ex.completed)).length, bmi: AppData.bmi, horasDormidas: horasDormidas, wasActive: ativoHoje);
     return [
    StatsModel(
      date: DateTime.now(),
      title: "Consumo de Água",
      unit: "L",
      icon: Icons.water_drop,
      color: Colors.blueAccent,
      isPercentage: false,
      labels: [hj.date.toIso8601String()],
      data: [hj.waterLiters],
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
      labels: [hj.date.toIso8601String()],
      data: [hj.completedActivities.toDouble()],
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
      labels: [hj.date.toIso8601String()],
      data: [hj.completedWorkouts.toDouble()],
      goal: AppData.treinos.where((el) => isHojeNaLista(el.diasSemana)).length.toDouble(),
      isBmi: false
    ),
    StatsModel(
      date: DateTime.now(),
      title: "Horas Dormidas",
      unit: "H",
      icon: Icons.bed,
      color: const Color.fromARGB(255, 166, 187, 255),
      isPercentage: false,
      labels: [hj.date.toIso8601String()],
      data: [hj.horasDormidas],
      goal: 8,
      isBmi: false
    ),
    StatsModel(
      date: DateTime.now(),
      title: "Dias Ativos",
      unit: "",
      icon: Icons.local_fire_department,
      color: Colors.redAccent,
      isPercentage: true,
      labels: [hj.date.toIso8601String()],
      data: [hj.wasActive ? 1.0 : 0.0],
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
      labels: [hj.date.toIso8601String()],
      data: [hj.bmi],
      goal: 0.0,
      isBmi: true
    ),
  ];
  }
}

// seta o imc
static void setBmi(double bmiImput){
  bmi = bmiImput;
  atualizarDailyStats(bmi: bmiImput);
  AppDataService.salvarTudo();
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
  double? horasDormidas,
  double? bmi,
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
    horasDormidas: statsHoje.horasDormidas + (horasDormidas ?? 0.0),
    wasActive: true,
    bmi: bmi ?? statsHoje.bmi,
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
}