import 'package:shared_preferences/shared_preferences.dart';

class DailyResetService {
  static Future<void> verificarEDefinirNovoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final hoje = DateTime.now().toIso8601String().substring(0, 10);
    final ultimoDia = prefs.getString('ultimo_dia_geral');

    if (hoje != ultimoDia) {
      await prefs.setString('ultimo_dia_geral', hoje);

      // Resetar dados de água
      prefs.setInt('waterConsumed', 0);

      // Resetar Treinos Diários
      prefs.setInt('treinosDiarios', 0);

      // Resetar atividades concluídas
      prefs.setDouble('bmi', 0);

      prefs.setInt('completedActivities', 0);

      prefs.setDouble('progress', 0.0);

      prefs.setDouble('horasDormidas', 0.0);
      


      print('Dados do dia resetados com sucesso!');
    }
  }
}
