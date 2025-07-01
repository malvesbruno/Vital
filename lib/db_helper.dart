import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('meu_app.db');
    return _db!;
  }

  static Future<Database> _initDB(String filePath) async {
    final path = join(await getDatabasesPath(), filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE treinos (
    id TEXT PRIMARY KEY,
    dados TEXT
  )
''');
await db.execute('''
  CREATE TABLE treinosSelecionados (
    id TEXT PRIMARY KEY,
    dados TEXT
  )
''');
await db.execute('''
  CREATE TABLE quickActions (
    id TEXT PRIMARY KEY,
    dados TEXT
  )
''');
await db.execute('''
  CREATE TABLE atividades (
    id TEXT PRIMARY KEY,
    dados TEXT
  )
''');
await db.execute('''
  CREATE TABLE stats (
    id TEXT PRIMARY KEY,
    dados TEXT
  )
''');
await db.execute('''
  CREATE TABLE historicoStats (
    id TEXT PRIMARY KEY,
    dados TEXT
  )
''');
await db.execute('''
  CREATE TABLE desafios_do_dia (
    id TEXT PRIMARY KEY,
    title TEXT,
    description TEXT,
    reward INTEGER,
    exp INTEGER,
    autoComplete INTEGER,
    completed INTEGER,
    assignedDate TEXT
  )
''');
await db.execute('''
  CREATE TABLE amigos (
    id TEXT PRIMARY KEY,
    nome TEXT,
    avatar TEXT,
    level INTEGER
  )
''');

await db.execute('''
  CREATE TABLE config (
    id TEXT PRIMARY KEY,
    ativo INTEGER,
    waterConsumed INTEGER,
    treinosDiarios INTEGER,
    coins INTEGER,
    name TEXT,
    ultimate INTEGER,
    exp INTEGER,
    level INTEGER,
    bmi REAL,
    currentAvatar TEXT,
    currentTheme TEXT,
    isExclusiveTheme INTEGER,
    completedActivities INTEGER,
    progress REAL,
    multiplicador INTEGER,
    steps INTEGER,
    ultimaDataSalva TEXT,
    idUser TEXT,
    horasDormidas REAL
  )
''');

    // Crie outras tabelas aqui: atividades, stats, amigos etc.
  }

  static Future<void> insert(String table, String id, Map<String, dynamic> json) async {
    final db = await database;
    await db.insert(
      table,
      {'id': id, 'dados': jsonEncode(json)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  static Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }
}
