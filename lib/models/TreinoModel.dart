import 'package:flutter/material.dart';

import 'ExercicioModel.dart';



class TreinoModel {
  String nome;
  List<int> diasSemana;
  List<ExercicioModel> exercicios;
  TimeOfDay horario;

  TreinoModel({
    required this.nome,
    required this.diasSemana,
    required this.exercicios,
    required this.horario,
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'diasSemana': diasSemana,
        'exercicios': exercicios.map((e) => e.toMap()).toList(),
      };

  factory TreinoModel.fromMap(Map<String, dynamic> map) => TreinoModel(
        nome: map['nome'],
        diasSemana: List<int>.from(map['diasSemana']),
        exercicios: (map['exercicios'] as List)
            .map((e) => ExercicioModel.fromMap(e))
            .toList(),
        horario: map['horario']
      );

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'diasSemana': diasSemana,
      'exercicios': exercicios.map((e) => e.toJson()).toList(),
      'horario': '${horario.hour}:${horario.minute}'
    };
  }


  factory TreinoModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTimeOfDay(String time) {
  final parts = time.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

    return TreinoModel(
      nome: json['nome'],
      diasSemana: List<int>.from(json['diasSemana']),
      exercicios: (json['exercicios'] as List)
          .map((e) => ExercicioModel.fromJson(e))
          .toList(),
          horario: parseTimeOfDay(json['horario']),
    );
  }
}

