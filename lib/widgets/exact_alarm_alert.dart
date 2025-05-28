import 'package:flutter/material.dart';

class ExactAlarmAlert extends StatelessWidget {
  const ExactAlarmAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Permissão de alarme exato necessária',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Para agendar notificações exatas, precisamos da permissão especial de alarme. Toque abaixo para ativá-la nas configurações.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 8),
        Text('Não conceder essa permissão pode evitar que as notificações funcionem corretamente', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)))
      ],
    );
  }
}
