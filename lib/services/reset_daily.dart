import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital/app_data.dart';
import '../models/AtividadeModel.dart';
import '../models/TreinoModel.dart';
import '../app_data_service.dart';
import '../models/DailyStatsModel.dart';

class DailyResetService {
  static Future<void> verificarEDefinirNovoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final hoje = DateTime.now().toIso8601String().substring(0, 10);
    final ultimoDia = prefs.getString('ultimo_dia_geral');

    if (hoje != ultimoDia) {
      await prefs.setString('ultimo_dia_geral', hoje);

      // 🔹 Salvar os dados do dia anterior
      await AppDataService.salvarStats();

      // 🔹 Resetar histórico diário
      if (AppData.historicoStats.isNotEmpty){
      AppData.historicoStats[0] = DailyStats.empty();
      }

      // 🔹 Resetar status de atividades
      for (AtividadeModel atividade in AppData.listaAtividades) {
        atividade.completed = false;
        await AppDataService.atualizarAtividade(atividade); // Atualiza no SQLite
      }

      // 🔹 Resetar status de treinos
      for (TreinoModel treino in AppData.treinos) {
        for (var exercicio in treino.exercicios) {
          exercicio.completed = false;
        }
        await AppDataService.atualizarTreino(treino); // Atualiza no SQLite
      }

      print('Dados do dia resetados com sucesso!');
    }
  }
}
