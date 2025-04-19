import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/TreinoModel.dart';
import '../models/AtividadeModel.dart';
import 'Notication.dart';


class Verificaragendamento {
  static Future<void> verficarAgendamento() async {
    final notificationService = NotificationService();

    bool isHojeNaLista(List<int> diasDaSemana) {
      int weekday = DateTime.now().weekday;
      return diasDaSemana.contains(weekday);
    }

    List<AtividadeModel> atividadesNotificate = AppData.listaAtividades
        .where((item) =>
            !item.completed && isHojeNaLista(item.dias))
        .toList();

    List<TreinoModel> treinosNotificate = AppData.treinos
        .where((item) => isHojeNaLista(item.diasSemana))
        .toList();

    for (var el in treinosNotificate) {
      TimeOfDay horas = el.horario;
      DateTime hoje = DateTime.now();
      DateTime horario = DateTime(hoje.year, hoje.month, hoje.day, horas.hour, horas.minute);
      if (horario.isAfter(DateTime.now())) {
        await notificationService.agendarNotificacao(
          titulo: 'Não se esqueça do ${el.nome}',
          id: el.nome.hashCode,
          corpo: 'Chegou a hora do seu treino. Não perca!',
          horario: horario,
        );
      }
    }

    for (var el in atividadesNotificate) {
       TimeOfDay horas = el.horario;
      DateTime hoje = DateTime.now();
      DateTime horario = DateTime(hoje.year, hoje.month, hoje.day, horas.hour, horas.minute);
      if (horario.isAfter(DateTime.now())) {
        await notificationService.agendarNotificacao(
          titulo: 'Hora de ${el.title}',
          id: el.title.hashCode,
          corpo: 'Chegou a hora de ${el.title}. Não perca!',
          horario: horario,
        );
      }
    }
  }
}


void agendamentoCallback() {
  Verificaragendamento.verficarAgendamento();
}
