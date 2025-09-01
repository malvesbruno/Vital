import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzi;
import 'package:vital/pages/MyHomePage.dart';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import 'package:timezone/timezone.dart' as tz;

// TO DO: adicionar notificação

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzi.initializeTimeZones();

    // Solicita permissão para notificações
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/icon_noti');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> mostrarNotificacao({
    int id = 0,
    required String titulo,
    required String corpo,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'Descrição do canal',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      titulo,
      corpo,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> agendarNotificacao({
  required String titulo,
  required String corpo,
  required DateTime horario,
  int id = 0,
  String? payload,
}) async {
  tzi.initializeTimeZones();

  final String timeZoneName = await tz.local.name; // pega o timezone atual
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  final tzScheduledDate = tz.TZDateTime.from(horario, tz.local);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    titulo,
    corpo,
    tzScheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'Descrição do canal',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    payload: payload,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
}

void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (payload != null) {
    print('Notification payload: $payload');
  }

  await navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => MyHomePage()),
  );
}
