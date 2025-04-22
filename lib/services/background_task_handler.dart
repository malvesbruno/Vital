// lib/services/background_task_handler.dart
import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../services/Notication.dart'; // ou onde estiver sua lógica de notificação
import '../app_data.dart';

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // Pode carregar dados aqui se necessário
    await AppData.carregarDados(); // se ainda não estiver carregado
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
  final now = DateTime.now();
  final horaAtual = now.hour;
  final minutoAtual = now.minute;
  final diaSemanaAtual = now.weekday; // 1 = segunda, 7 = domingo

  // Verifica atividades do AppData com horário próximo
  for (var atividade in AppData.listaAtividades) {
    if (
      !atividade.completed &&
      atividade.dias.contains(diaSemanaAtual) &&
      atividade.horario.hour == horaAtual &&
      (atividade.horario.minute - minutoAtual).abs() <= 5
    ) {
      await NotificationService().agendarNotificacao(
        id: atividade.hashCode,
        titulo: 'Lembrete de atividade',
        corpo: '${atividade.title} está marcada para agora.',
        horario: now.add(const Duration(seconds: 2)),
      );
    }
  }

  // Verifica treinos do AppData com horário próximo
  for (var treino in AppData.treinos) {
    if (
      treino.diasSemana.contains(diaSemanaAtual) &&
      treino.horario.hour == horaAtual &&
      (treino.horario.minute - minutoAtual).abs() <= 5
    ) {
      await NotificationService().agendarNotificacao(
        id: treino.hashCode,
        titulo: 'Hora do treino!',
        corpo: 'Você agendou: ${treino.nome}',
        horario: now.add(const Duration(seconds: 2)),
      );
    }
  }
}

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Limpa algo se necessário
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}
}
