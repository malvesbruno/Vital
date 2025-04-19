import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await _notificationsPlugin.initialize(initSettings);

  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt;

    if (sdkInt >= 33) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          print('Permissão de notificação negada.');
        }
      }
    }

    await _notificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(AndroidNotificationChannel(
      'canal_treino',
      'Lembretes de treino',
      description: 'Notificações para lembrar dos treinos',
      importance: Importance.max,
    ));

  }
}


  static int gerarId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<bool> _canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt;

    if (sdkInt < 31) return true;

    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return true;
    }

    // Tenta solicitar permissão
    final result = await Permission.scheduleExactAlarm.request();
    return result.isGranted;
  }

  Future<void> agendarNotificacao({
    required int id,
    required String titulo,
    required String corpo,
    required DateTime horario,
  }) async {
    final podeAgendar = await _canScheduleExactAlarms();

    if (!podeAgendar) {
      print('Permissão para alarme exato negada. Notificação não será agendada.');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_treino',
      'Lembretes de treino',
      channelDescription: 'Notificações para lembrar dos treinos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails detalhes = NotificationDetails(android: androidDetails);

    final tz.TZDateTime dataNotificacao = tz.TZDateTime.from(horario, tz.local);

    if (dataNotificacao.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Horário da notificação está no passado.');
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      titulo,
      corpo,
      dataNotificacao,
      detalhes,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
