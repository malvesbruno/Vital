import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/TreinoModel.dart';
import '../models/AtividadeModel.dart';
import '../services/Notication.dart';
import 'package:flutter/services.dart';


// TO DO: adicionar notificação

class Verificaragendamento {
  static Future<void> verficarAgendamento() async {
    final notificationService = NotificationService();
    await notificationService.init();

    bool isHojeNaLista(List<int> diasDaSemana) {
      int weekday = DateTime.now().weekday;
      return diasDaSemana.contains(weekday);
    }

    String gerarMensagemPorCategoria(String categoria, String tituloAtividade) {
  switch (categoria) {
    case 'Estudo':
      return 'Momento de focar nos estudos! 📚';
    case 'Trabalho':
      return 'Hora de trabalhar no seu sucesso! 💼';
    case 'Saúde':
      return 'Cuide de si mesmo agora! 🧘‍♂️';
    case 'Lazer':
      return 'Relaxe e aproveite! 🎮';
    case 'Social':
      return 'Momento de se conectar! 🤝';
    case 'Rotina':
      return 'Mais um passo na sua jornada! 🔁';
    case 'Outro':
      return 'Hora de $tituloAtividade!';
    default:
      return 'Hora de $tituloAtividade!';
  }
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

              final bool? canSchedule = await const MethodChannel('exact_alarm_permission')
          .invokeMethod('canScheduleExactAlarms');

      bool granted = false;

      // Se não puder agendar, solicita a permissão
      if (canSchedule == false) {
        await const MethodChannel('exact_alarm_permission')
            .invokeMethod('requestExactAlarmPermission');
        
        // Após solicitar, verifique novamente (pode demorar um pouco para atualizar)
        final bool? updatedCanSchedule = await const MethodChannel('exact_alarm_permission')
            .invokeMethod('canScheduleExactAlarms');
        
        if (updatedCanSchedule == true) {
          granted = true;
        }
      }

      // Se já tinha permissão ou acabou de ganhar, tenta agendar
      if (canSchedule == true || granted) {
        try {
          await notificationService.agendarNotificacao(
          titulo: '${el.nome.toUpperCase()}, hora de treinar! 🔥',
          id: el.nome.hashCode,
          corpo: 'Transforme esforço em conquista. Partiu treino!',
          horario: horario,
        );
        } catch (e, stackTrace) {
          print("Erro ao agendar notificação: $e\n$stackTrace");
        }
      } else {
        print("Permissão para alarmes exatos negada pelo usuário.");
      }
      }
    }

    for (var el in atividadesNotificate) {
  TimeOfDay horas = el.horario;
  DateTime hoje = DateTime.now();
  DateTime horario = DateTime(hoje.year, hoje.month, hoje.day, horas.hour, horas.minute);
  if (horario.isAfter(DateTime.now())) {

          final bool? canSchedule = await const MethodChannel('exact_alarm_permission')
          .invokeMethod('canScheduleExactAlarms');

      bool granted = false;

      // Se não puder agendar, solicita a permissão
      if (canSchedule == false) {
        await const MethodChannel('exact_alarm_permission')
            .invokeMethod('requestExactAlarmPermission');
        
        // Após solicitar, verifique novamente (pode demorar um pouco para atualizar)
        final bool? updatedCanSchedule = await const MethodChannel('exact_alarm_permission')
            .invokeMethod('canScheduleExactAlarms');
        
        if (updatedCanSchedule == true) {
          granted = true;
        }
      }

      // Se já tinha permissão ou acabou de ganhar, tenta agendar
      if (canSchedule == true || granted) {
        try {
          await notificationService.agendarNotificacao(
      titulo: 'Lembrete de ${el.title}',
      id: el.title.hashCode.abs(),
      corpo: gerarMensagemPorCategoria(el.categoria, el.title),
      horario: horario,
    );
        } catch (e, stackTrace) {
          print("Erro ao agendar notificação: $e\n$stackTrace");
        }
      } else {
        print("Permissão para alarmes exatos negada pelo usuário.");
      }
  }
}
  }
  static Future<void> notifacacaoDiaria() async{
    final notificationService = NotificationService();
    await notificationService.init();
    
          final bool? canSchedule = await const MethodChannel('exact_alarm_permission')
          .invokeMethod('canScheduleExactAlarms');

      bool granted = false;

      // Se não puder agendar, solicita a permissão
      if (canSchedule == false) {
        await const MethodChannel('exact_alarm_permission')
            .invokeMethod('requestExactAlarmPermission');
        
        // Após solicitar, verifique novamente (pode demorar um pouco para atualizar)
        final bool? updatedCanSchedule = await const MethodChannel('exact_alarm_permission')
            .invokeMethod('canScheduleExactAlarms');
        
        if (updatedCanSchedule == true) {
          granted = true;
        }
      }

      // Se já tinha permissão ou acabou de ganhar, tenta agendar
      if (canSchedule == true || granted) {
        try {
          DateTime hoje = DateTime.now();
    TimeOfDay horas = TimeOfDay(hour: 10, minute: 00);
    DateTime horario = DateTime(hoje.year, hoje.month, hoje.day, horas.hour, horas.minute);

    notificationService.agendarNotificacao(
          titulo: 'Hora de se hidratar! 💦',
          id: 'agua'.hashCode,
          corpo: 'Um copo d’água agora faz toda diferença no seu dia!',
          horario: horario,);
  
    horas = TimeOfDay(hour: 21, minute: 30);
    horario = DateTime(hoje.year, hoje.month, hoje.day, horas.hour, horas.minute);

    notificationService.agendarNotificacao(
          titulo: 'Desacelere... 🛏️',
          id: 'sono'.hashCode,
          corpo: 'O sono é seu aliado na jornada por mais saúde e disposição.',
        horario: horario,);

    horas = TimeOfDay(hour: 22, minute: 30);
    horario = DateTime(hoje.year, hoje.month, hoje.day, horas.hour, horas.minute);

    notificationService.agendarNotificacao(
          titulo: 'Seu corpo pede descanso 🛏️',
          id: 'sono2'.hashCode,
          corpo: 'Que tal se preparar para um bom sono?',
          horario: horario,);
        } catch (e, stackTrace) {
          print("Erro ao agendar notificação: $e\n$stackTrace");
        }
      } else {
        print("Permissão para alarmes exatos negada pelo usuário.");
      }
  }
  
}

@pragma('vm:entry-point')
void agendamentoCallback() {
  Verificaragendamento.verficarAgendamento();
}
