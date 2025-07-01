import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/TreinoModel.dart';
import '../models/ExercicioModel.dart';
import 'WorkoutComplete.dart';
import 'SetTreinoPage.dart';
import 'EditarTreinoPage.dart';
import 'dart:ui' as ui;
import '../app_data.dart';
import 'package:vital/themeNotifier.dart';
import 'package:provider/provider.dart';
import '../app_data_service.dart';
import '../cloud_service.dart';
import 'dart:convert';



class WorkoutPage extends StatefulWidget {
  final List<ExercicioModel> treinosDoDia;
  final List<TreinoModel> treino;

  const WorkoutPage({Key? key, required this.treinosDoDia, required this.treino}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with SingleTickerProviderStateMixin {

  TreinoModel getTreinoDoExercicio(ExercicioModel exercicio) {
  return widget.treino.firstWhere(
    (t) => t.exercicios.contains(exercicio),
    orElse: () => TreinoModel(nome: "Desconhecido", exercicios: [], diasSemana: [], horario: TimeOfDay(hour: 00, minute: 00), intensidade: 1), // caso não encontre
  );
}

  int currentExerciseIndex = 0;
  bool isTimerRunning = false;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration(minutes: 1);
  Duration timerDuration = Duration(minutes: 1);
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late final AudioPlayer _audioPlayer;
  late List<ExercicioModel> exerciciosDoDia;
  late TreinoModel treinoAtual;

  @override
  void initState() {
    super.initState();


    exerciciosDoDia = widget.treinosDoDia.where((e) => !e.completed).toList();
    exerciciosDoDia.isNotEmpty ? treinoAtual = getTreinoDoExercicio(exerciciosDoDia[currentExerciseIndex]): null;


    if (exerciciosDoDia.isNotEmpty) {
      final currentExercise = exerciciosDoDia[currentExerciseIndex];
      timerDuration = Duration(minutes: currentExercise.duration);
      _remainingTime = timerDuration;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(1.0);
  }



  void toggleTimer() {
    setState(() => isTimerRunning = !isTimerRunning);

    if (isTimerRunning) {
      _pulseController.repeat(reverse: true);
      _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime.inSeconds > 0) {
          setState(() => _remainingTime -= const Duration(seconds: 1));
        } else {
          timer.cancel();
          _pulseController.stop();
          _pulseController.value = 1.0;
          _audioPlayer.play(AssetSource('sounds/retro_game.mp3'));
          setState(() => isTimerRunning = false);
        }
      });
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
      _countdownTimer?.cancel();
    }
  }

  void nextExercise() {
    if (currentExerciseIndex < exerciciosDoDia.length - 1) {
      setState(() {
        currentExerciseIndex++;
        isTimerRunning = false;
        _countdownTimer?.cancel();

        final durationInMinutes = exerciciosDoDia[currentExerciseIndex].duration;
        timerDuration = Duration(minutes: durationInMinutes);
        treinoAtual = getTreinoDoExercicio(exerciciosDoDia[currentExerciseIndex]);
        _remainingTime = timerDuration;
      });

      _pulseController.stop();
    }
  }

  void previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
        isTimerRunning = false;
        _countdownTimer?.cancel();

        final durationInMinutes = exerciciosDoDia[currentExerciseIndex].duration;
        timerDuration = Duration(minutes: durationInMinutes);
        _remainingTime = timerDuration;
        treinoAtual = getTreinoDoExercicio(exerciciosDoDia[currentExerciseIndex]);
      });

      _pulseController.stop();
    }
  }

  void completeSet() async {
  final exercise = exerciciosDoDia[currentExerciseIndex];

  setState(() {
    exercise.completedSets++;

    if (exercise.completedSets >= exercise.sets) {
      exercise.completed = true;
      AppData.atualizarDailyStats(treinoConcluido: true);
      AppData.treinosDiarios++;

      if (exerciciosDoDia.every((e) => e.completed)) {
        // acabou tudo
        AppDataService.salvarTudo();
         AppData.ativoHoje = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WorkoutCompletePage()),
        );
        return;
      } else if (currentExerciseIndex >= exerciciosDoDia.length) {
        // Ajusta o índice se removemos o último da lista
        currentExerciseIndex = exerciciosDoDia.length - 1;
      }
    }

    // Atualiza o exercício atual e reinicia o timer
    final nextExercise = exerciciosDoDia[currentExerciseIndex];
    treinoAtual = getTreinoDoExercicio(nextExercise);
    timerDuration = Duration(minutes: nextExercise.duration);
    _remainingTime = timerDuration;
    isTimerRunning = false;
    _pulseController.stop();
    _pulseController.value = 1.0;
    _countdownTimer?.cancel();
  });

  await AppDataService.salvarTudo();
}


  String gerarFraseMotivacional(int reps) {
  final frases = [
    "Foco total! Complete as $reps reps e suba de nível!",
    "Cada uma das $reps reps te deixa mais forte.",
    "Você consegue! São só $reps reps entre você e a evolução!",
    "Bora quebrar limites — $reps reps, vai com tudo!",
    "Não é só treino, é transformação! Faça suas $reps reps!",
  ];
  frases.shuffle();
  return frases.first;
}

  int getReps(int intensidade){
    switch(intensidade){
      case(1):{
        return 18;
      }
      case(2):{
        return 12;
      }
      case(3):{
        return 6;
      }
      default:{
        return 18;
      }
    }
  }
  


  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if (exerciciosDoDia.isEmpty) {
      return 
      Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
  automaticallyImplyLeading: false,
  title: Text("Workouts", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
  backgroundColor: AppData.isExclusiveTheme ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
  elevation: 0,
),
        body: 
        Stack(children: [
          Consumer<ThemeNotifier>(builder: (context, themeNotifier, child){
        if (!AppData.isExclusiveTheme) {
      return const SizedBox.shrink(); // Não mostra nada
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(themeNotifier.currentTheme.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7), // 👈 escurece a imagem
            BlendMode.darken,
          ),
        ),
      ),
    );
    },),
          Center(
          child: Column(
            children: [
              Spacer(),
              Text(
                "Não Há exercícios para hoje...",
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SetTreinoPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const ui.Size(double.infinity, 50),
                  ),
                  child: Text("Adicionar Treinos", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
        ],)
        
      );
    }

    final exercise = exerciciosDoDia[currentExerciseIndex];
    final isWarning = _remainingTime <= Duration(minutes: 1);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
  automaticallyImplyLeading: false,
  title: Text("${treinoAtual.nome}", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
  backgroundColor: AppData.isExclusiveTheme ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
  elevation: 0,
  actions: [
    IconButton(
      icon: Icon(Icons.edit, color: Theme.of(context).textTheme.bodyLarge?.color),
      onPressed: () {
        // Leva para uma tela de edição passando o exercício atual
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditarTreinoPage(treino: treinoAtual)),
        );
      },
    ),
    IconButton(
      icon: Icon(Icons.delete, color: Colors.redAccent),
      onPressed: () async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Excluir exercício'),
      content: Text('Deseja realmente excluir este exercício?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Excluir', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmar == true) {
  final exercicioRemovido = exerciciosDoDia[currentExerciseIndex];

  setState(() {
    exerciciosDoDia.removeAt(currentExerciseIndex);
    AppData.treinos.removeWhere((e) => e.exercicios.contains(exercicioRemovido) && e.nome == treinoAtual.nome); // ou por ID se tiver
    if (currentExerciseIndex >= exerciciosDoDia.length) {
      currentExerciseIndex = exerciciosDoDia.length - 1;
    }
  });
  if (AppData.ultimate){
      final treinosJson = AppData.treinos.map((t) => t.toJson()).toList();
      final statsJson = AppData.historicoStats.map((t) => t.toJson()).toList();
      BackupService cloud = BackupService();
      await cloud.updateUser(AppData.id, {
        'treinos': jsonEncode(treinosJson),
        'stats': jsonEncode(statsJson),
        'current_avatar': AppData.currentAvatar,
        'current_theme': AppData.currentTheme,
        'nivel': AppData.level,
        'coins': AppData.coins,
      });
      }
  await AppDataService.salvarTudo();
  }
},
    )
  ],
),
      body: 
      Stack(children: [
        Consumer<ThemeNotifier>(builder: (context, themeNotifier, child){
        if (!AppData.isExclusiveTheme) {
      return const SizedBox.shrink(); // Não mostra nada
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(themeNotifier.currentTheme.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.8), // 👈 escurece a imagem
            BlendMode.darken,
          ),
        ),
      ),
    );
    },),
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            SizedBox(height: 10),
            Text("${exercise.sets} sets", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4))),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: toggleTimer,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(scale: _pulseAnimation.value, child: child);
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    alignment: Alignment.center,
                    child: Text(
                      "${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: isWarning ? Colors.redAccent : Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Clique abaixo para finalizar set", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4))),
            ],),
            SizedBox(height: 10,),
            Center(
  child: Wrap(
    alignment: WrapAlignment.center,
    spacing: 8,
    runSpacing: 8,
    children: List.generate(exercise.sets, (index) {
      final isCompleted = index < exercise.completedSets;
      return ElevatedButton(
        onPressed: () {
          if (!isTimerRunning && !isCompleted) {
            setState(() {
      exercise.completedSets++;
      final isLastSet = exercise.completedSets >= exercise.sets;

      if (isLastSet) {
        completeSet(); // finaliza o exercício
      } else {
        // Inicia o timer automaticamente após concluir o set
        _remainingTime = Duration(minutes: exercise.duration);
        toggleTimer(); // inicia o timer
      }
    });
  }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.green : Theme.of(context).primaryColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(5),
        ),
        child: isCompleted
            ? Icon(Icons.check, color: Theme.of(context).textTheme.bodyLarge?.color)
            : Text(''),
      );
    }),
  ),
),
            SizedBox(height: 20,),
            Center(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children:[ 
                Padding(padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text("${getReps(treinoAtual.intensidade)} Repetições", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4), fontSize: 20),),)
            ],),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color), onPressed: previousExercise),
                IconButton(icon: Icon(Icons.arrow_forward, color: Theme.of(context).textTheme.bodyLarge?.color), onPressed: nextExercise),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SetTreinoPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const ui.Size(double.infinity, 50),
              ),
              child: Text("Adicionar Treinos", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ],
        ),
      ),
      ],)
    );
  }
}
