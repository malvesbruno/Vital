import 'dart:convert';

import 'package:flutter/material.dart';

import 'ExercicioModel.dart';



class TreinoModel {
  String nome;
  List<int> diasSemana;
  List<ExercicioModel> exercicios;
  TimeOfDay horario;
  int intensidade;

  TreinoModel({
    required this.nome,
    required this.diasSemana,
    required this.exercicios,
    required this.horario,
    required this.intensidade,
  });

  /// Construtor vazio com valores padrão
  TreinoModel.empty()
      : nome = 'Sem treino definido',
        diasSemana = [],
        exercicios = [],
        horario = const TimeOfDay(hour: 0, minute: 0),
        intensidade = 0;

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'diasSemana': jsonEncode(diasSemana),
        'exercicios': jsonEncode(exercicios.map((e) => e.toJson()).toList()),
        'horario': '${horario.hour}:${horario.minute}',
        'intensidade': intensidade,
      };

  factory TreinoModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay parseTimeOfDay(String time) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return TreinoModel(
      nome: map['nome'],
      diasSemana: List<int>.from(jsonDecode(map['diasSemana'])),
      exercicios: (jsonDecode(map['exercicios']) as List)
          .map((e) => ExercicioModel.fromJson(e))
          .toList(),
      horario: parseTimeOfDay(map['horario']),
      intensidade: map['intensidade'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'diasSemana': jsonEncode(diasSemana),
        'exercicios': jsonEncode(exercicios.map((e) => e.toJson()).toList()),
        'horario': '${horario.hour}:${horario.minute}',
        'intensidade': intensidade,
      };

  factory TreinoModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTimeOfDay(String time) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return TreinoModel(
      nome: json['nome'],
      diasSemana: List<int>.from(jsonDecode(json['diasSemana'])),
      exercicios: (jsonDecode(json['exercicios']) as List)
          .map((e) => ExercicioModel.fromJson(e))
          .toList(),
      horario: parseTimeOfDay(json['horario']),
      intensidade: json['intensidade'],
    );
  }
}
