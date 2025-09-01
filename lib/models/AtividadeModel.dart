import 'package:flutter/material.dart';


//modelo de atividade
class AtividadeModel {
  final String title;
  final String categoria;
  final TimeOfDay horario;
  final List<int> dias;
  bool completed;

  AtividadeModel({
    required this.title,
    required this.categoria,
    required this.horario,
    required this.dias,
    this.completed = false,
  });

  /// Construtor vazio seguro
  AtividadeModel.empty()
      : title = 'Sem atividade definida',
        categoria = 'Geral',
        horario = const TimeOfDay(hour: 0, minute: 0),
        dias = [],
        completed = false;

  factory AtividadeModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTimeOfDay(String time) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return AtividadeModel(
      title: json['title'],
      categoria: json['categoria'],
      horario: parseTimeOfDay(json['horario']),
      dias: List<int>.from(json['dias']),
      completed: json['completed'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'categoria': categoria,
      'horario': '${horario.hour}:${horario.minute}',
      'dias': dias,
      'completed': completed ? 1 : 0,
    };
  }
}
