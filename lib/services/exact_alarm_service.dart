import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('exact_alarm_permission');

// TO DO: adicionar notificação

Future<void> openExactAlarmSettings() async {
  try {
    await _channel.invokeMethod('requestExactAlarmPermission');
  } on PlatformException catch (e) {
    // Você pode mostrar um SnackBar ou printar o erro, se quiser
    print('Erro ao solicitar permissão de alarme exato: $e');
  }
}