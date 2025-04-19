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
    orElse: () => TreinoModel(nome: "Desconhecido", exercicios: [], diasSemana: [], horario: TimeOfDay(hour: 00, minute: 00)), // caso não encontre
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
  setState(() {
    final exercise = exerciciosDoDia[currentExerciseIndex];
    exercise.completedSets++;
    exerciciosDoDia.isNotEmpty
        ? treinoAtual = getTreinoDoExercicio(exerciciosDoDia[currentExerciseIndex])
        : null;

    if (exercise.completedSets >= exercise.sets) {
      exercise.completed = true;
      exerciciosDoDia.removeAt(currentExerciseIndex);

      if (currentExerciseIndex >= exerciciosDoDia.length) {
        currentExerciseIndex = exerciciosDoDia.length - 1;
      }

      if (exerciciosDoDia.isEmpty) {
        // Aqui salvamos antes de trocar de tela
        AppData.salvarDados(); // não precisa de await aqui porque estamos dentro do setState
        AppData.atualizarDailyStats(treinoConcluido: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WorkoutCompletePage()),
        );
        return;
      }

      final durationInMinutes = exerciciosDoDia[currentExerciseIndex].duration;
      timerDuration = Duration(minutes: durationInMinutes);
      _remainingTime = timerDuration;

      _countdownTimer?.cancel();
      isTimerRunning = false;
    }
  });

  // Aqui salvamos fora do setState pra garantir que o estado foi aplicado primeiro
  await AppData.salvarDados();
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
      return Scaffold(
        backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
        appBar: AppBar(
  automaticallyImplyLeading: false,
  title: Text("Workouts", style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
  backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
  elevation: 0,
),
        body: Center(
          child: Column(
            children: [
              Spacer(),
              Text(
                "Não Há exercícios para hoje...",
                style: TextStyle(color: Colors.white, fontSize: 18),
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
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const ui.Size(double.infinity, 50),
                  ),
                  child: Text("Adicionar Treinos", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      );
    }

    final exercise = exerciciosDoDia[currentExerciseIndex];
    final isWarning = _remainingTime <= Duration(minutes: 1);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
      appBar: AppBar(
  automaticallyImplyLeading: false,
  title: Text("${treinoAtual.nome}", style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
  backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
  elevation: 0,
  actions: [
    IconButton(
      icon: Icon(Icons.edit, color: Colors.white),
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

  await AppData.salvarDados();
  }
},
    )
  ],
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            Text("${exercise.sets} sets", style: TextStyle(fontSize: 16, color: Colors.white70)),
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[900]),
                    alignment: Alignment.center,
                    child: Text(
                      "${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: isWarning ? Colors.redAccent : Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(exercise.sets, (index) {
                return IconButton(
                  icon: Icon(
                    index < exercise.completedSets ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: Colors.green,
                  ),
                  onPressed: completeSet,
                );
              }),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: previousExercise),
                IconButton(icon: Icon(Icons.arrow_forward, color: Colors.white), onPressed: nextExercise),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SetTreinoPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const ui.Size(double.infinity, 50),
              ),
              child: Text("Adicionar Treinos", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
