import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/DailyChallenge.dart';
import '../services/challenge_completed.dart';

class ChallengeService {
  static final List<DailyChallengeModel> _todosDesafios = [
  DailyChallengeModel(title: 'Beber 2L de água', description: 'Mantenha-se hidratado!', reward: 15, exp: 12, autoComplete: true),
  DailyChallengeModel(title: 'Fazer 1 treino completo', description: 'Treinar é vida!', reward: 20, exp: 18, autoComplete: true),
  DailyChallengeModel(title: 'Alongar-se por 5 minutos', description: 'Solte a tensão do corpo.', reward: 10, exp: 8, autoComplete: false),
  DailyChallengeModel(title: 'Fazer 20 agachamentos', description: 'Fortaleça suas pernas!', reward: 10, exp: 9, autoComplete: false),
  DailyChallengeModel(title: 'Dar uma caminhada de 10 minutos', description: 'Movimento é tudo.', reward: 12, exp: 10, autoComplete: false),
  DailyChallengeModel(title: 'Subir escadas em vez de usar elevador', description: 'Bora suar um pouco!', reward: 10, exp: 9, autoComplete: false),
  DailyChallengeModel(title: 'Fazer 15 flexões', description: 'Mostre sua força!', reward: 12, exp: 10, autoComplete: false),
  DailyChallengeModel(title: 'Ficar 1h sem usar o celular', description: 'Liberdade mental.', reward: 15, exp: 13, autoComplete: false),
  DailyChallengeModel(title: 'Fazer uma respiração profunda por 2 minutos', description: 'Acalme a mente.', reward: 8, exp: 6, autoComplete: false),
  DailyChallengeModel(title: 'Escrever 1 coisa pela qual você é grato hoje', description: 'Cultive gratidão.', reward: 10, exp: 8, autoComplete: false),
  DailyChallengeModel(title: 'Ficar 30 minutos sem redes sociais', description: 'Detox digital.', reward: 10, exp: 8, autoComplete: false),
  DailyChallengeModel(title: 'Ouvir sua música favorita com atenção total', description: 'Curta o momento.', reward: 8, exp: 6, autoComplete: false),
  DailyChallengeModel(title: 'Fazer uma boa ação simples', description: 'Espalhe gentileza.', reward: 10, exp: 8, autoComplete: false),
  DailyChallengeModel(title: 'Tomar os medicamentos corretamente', description: 'Saúde em dia!', reward: 10, exp: 10, autoComplete: true),
  DailyChallengeModel(title: 'Dormir pelo menos 7h na última noite', description: 'O descanso é essencial.', reward: 15, exp: 14, autoComplete: false),
  DailyChallengeModel(title: 'Completar suas atividade diária', description: 'Mantenha sua rotina no eixo.', reward: 10, exp: 10, autoComplete: true),
  DailyChallengeModel(title: 'Planejar seu dia pela manhã', description: 'Comece com intenção.', reward: 10, exp: 9, autoComplete: false),
  DailyChallengeModel(title: 'Evitar açúcar por 1 refeição', description: 'Pequenas vitórias contam!', reward: 10, exp: 9, autoComplete: false),
  DailyChallengeModel(title: 'Ler por 10 minutos', description: 'Alimente sua mente.', reward: 10, exp: 9, autoComplete: false),
  DailyChallengeModel(title: 'Organizar um espaço da casa', description: 'Ambiente limpo, mente leve.', reward: 10, exp: 9, autoComplete: false),
];

  static Future<void> inicializarDesafios() async {
  final prefs = await SharedPreferences.getInstance();
  final hoje = DateTime.now().toIso8601String().substring(0, 10);
  final ultimoDia = prefs.getString('ultimo_dia_desafios');
  final desafiosSalvos = prefs.getStringList('desafios_do_dia');

  // Gera novos desafios se for um novo dia ou os dados estiverem faltando
  if (hoje != ultimoDia || desafiosSalvos == null || desafiosSalvos.isEmpty) {
    final desafiosAleatorios = List<DailyChallengeModel>.from(_todosDesafios)..shuffle();
    final escolhidos = desafiosAleatorios.take(2).toList();

    prefs.setString('ultimo_dia_desafios', hoje);
    prefs.setStringList(
      'desafios_do_dia',
      escolhidos.map((d) => jsonEncode(d.toJson())).toList(),
    );

    print('Desafios do dia gerados!');
  }
}

  static Future<List<DailyChallengeModel>> carregarDesafiosDoDia() async {
  final prefs = await SharedPreferences.getInstance();
  final challengesJson = prefs.getStringList('desafios_do_dia');

  if (challengesJson != null && challengesJson.isNotEmpty) {
    try {
      return challengesJson
          .map((jsonStr) => DailyChallengeModel.fromJson(jsonDecode(jsonStr)))
          .toList();
    } catch (e) {
      print('Erro ao carregar desafios: $e');
      // Se der erro, continua para gerar novos
    }
  }

  // Garante que desafios sejam criados se não existirem
  await inicializarDesafios();

  // Agora tenta carregar novamente os desafios recém-criados
  final novosChallengesJson = prefs.getStringList('desafios_do_dia');
  if (novosChallengesJson != null && novosChallengesJson.isNotEmpty) {
    try {
      return novosChallengesJson
          .map((jsonStr) => DailyChallengeModel.fromJson(jsonDecode(jsonStr)))
          .toList();
    } catch (e) {
      print('Erro ao recarregar desafios após criação: $e');
    }
  }

  // Se ainda assim falhar, retorna vazio
  return [];
}


  static Future<void> marcarComoConcluido(DailyChallengeModel desafio) async {
    final lista = await carregarDesafiosDoDia();
    final index = lista.indexWhere((d) => d.title == desafio.title);
    if (index != -1) {
      lista[index].completed = true;
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
  'desafios_do_dia',
  lista.map((e) => jsonEncode(e.toJson())).toList(),
);
    }
  }

  static Future<void> verificarDesafiosAutomaticos() async {
  final desafios = await carregarDesafiosDoDia();

  for (var desafio in desafios) {
    if (!desafio.completed) {
      if (desafio.title == 'Fazer 1 treino completo' && verificarTreino()) {
        await marcarComoConcluido(desafio);
      }
      else if (desafio.title == 'Tomar os medicamentos corretamente' && verificarMedicamento()) {
        await marcarComoConcluido(desafio);
      }
      else if (desafio.title == 'Beber 2L de água' && verificarAgua()) {
        await marcarComoConcluido(desafio);
      }
      else if (desafio.title == 'Completar uma atividade diária' && verificarAtividade()) {
        await marcarComoConcluido(desafio);
      }
    }
  }
}

}
