import '../models/DailyChallenge.dart';
import '../services/challenge_completed.dart';
import '../db_helper.dart';


// Serviço que atualiza os desafio diários 

class ChallengeService {
  static final List<DailyChallengeModel> _todosDesafios = [
    DailyChallengeModel(
      title: 'Beber 2L de água',
      description: 'Mantenha-se hidratado!',
      reward: 15,
      exp: 12,
      autoComplete: true,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Fazer 1 treino completo',
      description: 'Treinar é vida!',
      reward: 20,
      exp: 18,
      autoComplete: true,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Alongar-se por 5 minutos',
      description: 'Solte a tensão do corpo.',
      reward: 10,
      exp: 8,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Fazer 20 agachamentos',
      description: 'Fortaleça suas pernas!',
      reward: 10,
      exp: 9,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Dar uma caminhada de 10 minutos',
      description: 'Movimento é tudo.',
      reward: 12,
      exp: 10,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Subir escadas em vez de usar elevador',
      description: 'Bora suar um pouco!',
      reward: 10,
      exp: 9,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Fazer 15 flexões',
      description: 'Mostre sua força!',
      reward: 12,
      exp: 10,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Ficar 1h sem usar o celular',
      description: 'Liberdade mental.',
      reward: 15,
      exp: 13,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Fazer uma respiração profunda por 2 minutos',
      description: 'Acalme a mente.',
      reward: 8,
      exp: 6,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Escrever 1 coisa pela qual você é grato hoje',
      description: 'Cultive gratidão.',
      reward: 10,
      exp: 8,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Ficar 30 minutos sem redes sociais',
      description: 'Detox digital.',
      reward: 10,
      exp: 8,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Ouvir sua música favorita com atenção total',
      description: 'Curta o momento.',
      reward: 8,
      exp: 6,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Fazer uma boa ação simples',
      description: 'Espalhe gentileza.',
      reward: 10,
      exp: 8,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Tomar os medicamentos corretamente',
      description: 'Saúde em dia!',
      reward: 10,
      exp: 10,
      autoComplete: true,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Dormir pelo menos 7h na última noite',
      description: 'O descanso é essencial.',
      reward: 15,
      exp: 14,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Completar suas atividade diária',
      description: 'Mantenha sua rotina no eixo.',
      reward: 10,
      exp: 10,
      autoComplete: true,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Planejar seu dia pela manhã',
      description: 'Comece com intenção.',
      reward: 10,
      exp: 9,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Evitar açúcar por 1 refeição',
      description: 'Pequenas vitórias contam!',
      reward: 10,
      exp: 9,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Ler por 10 minutos',
      description: 'Alimente sua mente.',
      reward: 10,
      exp: 9,
      autoComplete: false,
      assignedDate: '',
    ),
    DailyChallengeModel(
      title: 'Organizar um espaço da casa',
      description: 'Ambiente limpo, mente leve.',
      reward: 10,
      exp: 9,
      autoComplete: false,
      assignedDate: '',
    ),
  ];
 

  // inicia os desafios
  static Future<void> inicializarDesafios() async {
    final db = await DBHelper.database;
    final hoje = DateTime.now().toIso8601String().substring(0, 10);

    final resultados = await db.query(
      'desafios_do_dia',
      where: 'assignedDate = ?',
      whereArgs: [hoje],
    );

    if (resultados.isEmpty) {
      final desafiosAleatorios = List<DailyChallengeModel>.from(_todosDesafios)..shuffle();
      final escolhidos = desafiosAleatorios.take(2).toList();

      final batch = db.batch();
      for (var desafio in escolhidos) {
        final desafioComData = DailyChallengeModel(
          title: desafio.title,
          description: desafio.description,
          reward: desafio.reward,
          exp: desafio.exp,
          completed: false,
          autoComplete: desafio.autoComplete,
          assignedDate: hoje,
        );
        batch.insert('desafios_do_dia', desafioComData.toMap());
      }
      await batch.commit(noResult: true);
      print('Desafios do dia gerados!');
    }
  }

  // carrega os desafios
  static Future<List<DailyChallengeModel>> carregarDesafiosDoDia() async {
    final db = await DBHelper.database;
    final hoje = DateTime.now().toIso8601String().substring(0, 10);

    final resultados = await db.query(
      'desafios_do_dia',
      where: 'assignedDate = ?',
      whereArgs: [hoje],
    );

    if (resultados.isEmpty) {
      await inicializarDesafios();
      return carregarDesafiosDoDia();
    }

    return resultados.map((e) => DailyChallengeModel.fromMap(e)).toList();
  }
 

  //marcar como concluído 
  static Future<void> marcarComoConcluido(DailyChallengeModel desafio) async {
    final db = await DBHelper.database;
    final hoje = DateTime.now().toIso8601String().substring(0, 10);

    await db.update(
      'desafios_do_dia',
      {'completed': 1},
      where: 'title = ? AND assignedDate = ?',
      whereArgs: [desafio.title, hoje],
    );
  }

  // verificar desafios automaticamente

  static Future<void> verificarDesafiosAutomaticos() async {
    final desafios = await carregarDesafiosDoDia();

    for (var desafio in desafios) {
      if (!desafio.completed) {
        if (desafio.title == 'Fazer 1 treino completo' && verificarTreino()) {
          await marcarComoConcluido(desafio);
        } else if (desafio.title == 'Tomar os medicamentos corretamente' && verificarMedicamento()) {
          await marcarComoConcluido(desafio);
        } else if (desafio.title == 'Beber 2L de água' && verificarAgua()) {
          await marcarComoConcluido(desafio);
        } else if (desafio.title == 'Completar suas atividade diária' && verificarAtividade()) {
          await marcarComoConcluido(desafio);
        }
      }
    }
  }
}
