import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:vital/models/AmigoModel.dart';
import 'dart:convert';
import 'models/TreinoModel.dart';
import 'models/AtividadeModel.dart';
import '../db_helper.dart'; // sua classe SQLite com getDatabase()
import '../app_data.dart';
import '../models/DailyChallenge.dart';
import '../models/DailyStatsModel.dart';
import '../models/QuickAction.dart';

class AppDataService {
  // Salva tudo (SQLite + backup em SharedPreferences)
  static Future<void> salvarTudo() async {
    await _salvarTreinos();
    await _salvarAtividades();
    await _salvarConfiguracoes();
    await _salvarBackupSharedPrefs();
    await _salvarAmigos();
    await _salvarDesafiosDoDia();
    await _salvarHistoricoStats();
    await _salvarQuickActions();
    await salvarStats();
  }

  // Carrega tudo (SQLite)
  static Future<void> carregarTudo() async {
    await _carregarTreinos();
    await _carregarAtividades();
    await _carregarConfiguracoes();
    await _carregarAmigos();
    await _carregarDesafiosDoDia();
    await _carregarHistoricoStats();
    await _carregarQuickActions();
    await _carregarStats();
  }

  // -------- TREINOS --------
  static Future<void> _salvarTreinos() async {
    final db = await DBHelper.database;
    final batch = db.batch();

    await db.delete('treinos'); // limpa tabela antes de salvar
    for (var treino in AppData.treinos) {
      batch.insert('treinos', {
        'id': treino.nome,
        'dados': jsonEncode(treino.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _carregarTreinos() async {
    final db = await DBHelper.database;
    final maps = await db.query('treinos');
    AppData.treinos = maps.map((e) {
      final dadosStr = e['dados'] as String?;
      if (dadosStr == null || dadosStr.isEmpty) {
        // retorna um objeto padrão ou nulo para evitar erro
        return TreinoModel.empty(); // ou TreinoModel.vazio() se tiver construtor assim
      }
      final json = jsonDecode(dadosStr);
      return TreinoModel.fromJson(json);
    }).toList();
  }

  // -------- ATIVIDADES --------
  static Future<void> _salvarAtividades() async {
    final db = await DBHelper.database;
    final batch = db.batch();

    await db.delete('atividades'); // limpa tabela antes de salvar
    for (var atividade in AppData.listaAtividades) {
      batch.insert('atividades', {
        'id': atividade.title,
        'dados': jsonEncode(atividade.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _carregarAtividades() async {
    final db = await DBHelper.database;
    final maps = await db.query('atividades');

    AppData.listaAtividades = maps.map((e) {
      final dadosStr = e['dados'] as String?;
      if (dadosStr == null || dadosStr.isEmpty) {
        return AtividadeModel.empty(); // objeto padrão para evitar erro
      }
      final dados = jsonDecode(dadosStr);
      return AtividadeModel.fromJson(dados);
    }).toList();
  }

  // -------- AMIGOS ------- //
  static Future<void> _salvarAmigos() async {
    final db = await DBHelper.database;
    final batch = db.batch();

    await db.delete('amigos'); // limpa tabela antes de salvar
    for (var amigo in AppData.amigos) {
      batch.insert('amigos', amigo.toJson());
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _carregarAmigos() async {
    final db = await DBHelper.database;
    final maps = await db.query('amigos');
    AppData.amigos = maps.map((e) => AmigoModel.fromJson(e)).toList();
  }

  // ---------- QuickActions--------------

  static Future<void> _salvarQuickActions() async {
    final db = await DBHelper.database;
    final batch = db.batch();

    await db.delete('quickActions');
    for (var item in AppData.quickActions) {
      batch.insert('quickActions', {
        'id': item.name,
        'dados': jsonEncode(item.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _carregarQuickActions() async {
    final db = await DBHelper.database;
    final maps = await db.query('quickActions');
    AppData.quickActions = maps.map((e) {
      final dadosStr = e['dados'] as String?;
      if (dadosStr == null || dadosStr.isEmpty) {
        return QuickAction.empty(); // padrão para evitar erro
      }
      return QuickAction.fromJson(jsonDecode(dadosStr));
    }).toList();
  }

  // ---- HISTORICO DE STATS --------

  static Future<void> _salvarHistoricoStats() async {
    final db = await DBHelper.database;
    final batch = db.batch();

    await db.delete('historicoStats');
    for (var item in AppData.historicoStats) {
      batch.insert('historicoStats', {
        'id': item.date.toIso8601String(),
        'dados': jsonEncode(item.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _carregarHistoricoStats() async {
    final db = await DBHelper.database;
    final maps = await db.query('historicoStats');
    AppData.dailyStats = maps.map((e) {
      final dadosStr = e['dados'] as String?;
      if (dadosStr == null || dadosStr.isEmpty) {
        return DailyStats.empty(); // padrão para evitar erro
      }
      return DailyStats.fromJson(jsonDecode(dadosStr));
    }).toList();
  }

  // --- STATS DO DIA ATUAL ---

  static Future<void> salvarStats() async {
    final db = await DBHelper.database;
    if (AppData.historicoStats.isNotEmpty) {
      await db.delete('stats'); // limpa a tabela
      await db.insert('stats', {
        'id': 'stats_hoje',
        'dados': jsonEncode(AppData.historicoStats[0].toJson()),
      });
    }
  }

  static Future<void> _carregarStats() async {
    final db = await DBHelper.database;
    final maps = await db.query('stats', where: 'id = ?', whereArgs: ['stats_hoje']);
    if (maps.isNotEmpty) {
      final dadosStr = maps.first['dados'] as String?;
      if (dadosStr == null || dadosStr.isEmpty) {
        // evita erro ao decodificar string vazia
        return;
      }
      final dados = jsonDecode(dadosStr);
      if (AppData.historicoStats.isEmpty) {
        AppData.historicoStats.add(DailyStats.fromJson(dados));
      } else {
        AppData.historicoStats[0] = DailyStats.fromJson(dados);
      }
    }
  }

  // --------- DESAFIOS DO DIA -----//

  static Future<void> _salvarDesafiosDoDia() async {
    final db = await DBHelper.database;
    final batch = db.batch();

    await db.delete('desafios_do_dia');
    for (var item in AppData.dailyChallenges) {
      batch.insert('desafios_do_dia', {
        'id': item.title,
        'title': item.title,
        'description': item.description,
        'reward': item.reward,
        'exp': item.exp,
        'completed': item.completed ? 1 : 0,
        'assignedDate': item.assignedDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _carregarDesafiosDoDia() async {
  final db = await DBHelper.database;
  final maps = await db.query('desafios_do_dia');

  AppData.dailyChallenges = maps.map((e) {
    return DailyChallengeModel(
      title: e['title'] as String? ?? '',
      description: e['description'] as String? ?? '',
      reward: e['reward'] as int? ?? 0,
      exp: e['exp'] as int? ?? 0,
      completed: (e['completed'] as int? ?? 0) == 1,
      autoComplete: false, 
      assignedDate: e['assignedDate'] as String? ?? '', 
    );
  }).toList();
}
  // --------- Atualizar ----------
  static Future<void> atualizarTreino(TreinoModel treino) async {
    final db = await DBHelper.database;
    await db.update(
      'treinos',
      {
        'dados': jsonEncode(treino.toJson()),
      },
      where: 'id = ?',
      whereArgs: [treino.nome],
    );
  }

  static Future<void> atualizarAtividade(AtividadeModel atividade) async {
    final db = await DBHelper.database;
    await db.update(
      'atividades',
      {
        'dados': jsonEncode(atividade.toJson()),
      },
      where: 'id = ?',
      whereArgs: [atividade.title],
    );
  }

  // -------- CONFIGURAÇÕES --------
  static Future<void> _salvarConfiguracoes() async {
    final db = await DBHelper.database;

    await db.delete('config'); // limpa tabela config antes de salvar

    await db.insert('config', {
      'id': AppData.id,
      'ativo': AppData.ativoHoje ? 1 : 0,
      'waterConsumed': AppData.waterConsumed,
      'treinosDiarios': AppData.treinosDiarios,
      'coins': AppData.coins,
      'name': AppData.name,
      'ultimate': AppData.ultimate ? 1 : 0,
      'exp': AppData.exp,
      'level': AppData.level,
      'bmi': "${AppData.bmi}",
      'currentAvatar': AppData.currentAvatar,
      'currentTheme': AppData.currentTheme,
      'isExclusiveTheme': AppData.isExclusiveTheme ? 1 : 0,
      'completedActivities': AppData.completedActivities,
      'progress': "${AppData.progress}",
      'multiplicador': AppData.multiplicador,
      'steps': AppData.steps,
      'ultimaDataSalva': AppData.ultimaDataSalva.toIso8601String(),
      'idUser': AppData.id,
      'horasDormidas': "${AppData.horasDormidas}",
    },
    conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> _carregarConfiguracoes() async {
  final db = await DBHelper.database;
  final list = await db.query('config');
  if (list.isNotEmpty) {
    final config = list.first;
    AppData.level = config['level'] as int? ?? 1;
    AppData.coins = config['coins'] as int? ?? 0;
    AppData.ativoHoje = (config['ativo'] as int? ?? 0) == 1; 
    AppData.currentAvatar = config['currentAvatar'] as String? ?? '';
    AppData.id = config['id'] as String? ?? '';
    AppData.waterConsumed = config['waterConsumed'] as int? ?? 0;
    AppData.treinosDiarios = config['treinosDiarios'] as int? ?? 0;
    AppData.name = config['name'] as String? ?? '';
    AppData.ultimate = (config['ultimate'] as int? ?? 0) == 1;
    AppData.exp = config['exp'] as int? ?? 0;

    // Modificação para evitar erro double/string
    AppData.bmi = _parseDouble(config['bmi']);
    
    AppData.currentTheme = config['currentTheme'] as String? ?? '';
    AppData.isExclusiveTheme = (config['isExclusiveTheme'] as int? ?? 0) == 1;
    AppData.completedActivities = config['completedActivities'] as int? ?? 0;
    
    AppData.progress = _parseDouble(config['progress']);
    
    AppData.multiplicador = config['multiplicador'] as int? ?? 1;
    AppData.steps = config['steps'] as int? ?? 0;

    final ultimaDataStr = config['ultimaDataSalva'] as String? ?? '';
    if (ultimaDataStr.isNotEmpty) {
      AppData.ultimaDataSalva = DateTime.parse(ultimaDataStr);
    }
    
    AppData.id = config['idUser'] as String? ?? '';
    AppData.horasDormidas = _parseDouble(config['horasDormidas']);
  }
}

// Função auxiliar para converter de forma segura valores que podem ser int, double ou string
static double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}


  // -------- BACKUP (SharedPreferences) --------
  static Future<void> _salvarBackupSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Salva treinos em backup no SharedPreferences (string JSON)
    final treinosJson = AppData.treinos.map((t) => t.toJson()).toList();
    await prefs.setString('backup_treinos', jsonEncode(treinosJson));

    // Similar para atividades, amigos, etc, se desejar
  }

  static Future<void> carregarBackupSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final treinosStr = prefs.getString('backup_treinos');
    if (treinosStr != null && treinosStr.isNotEmpty) {
      try {
        final List<dynamic> treinosJson = jsonDecode(treinosStr);
        AppData.treinos = treinosJson.map((e) => TreinoModel.fromJson(e)).toList();
      } catch (e) {
        // Falha ao carregar backup, pode logar ou tratar
      }
    }
  }
}
