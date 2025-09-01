import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../app_data.dart';
import 'WorkoutComplete.dart';
import '../app_data_service.dart';


// página de treino rápido

class WorkoutPagePersonalizado extends StatefulWidget {
  final List<Map<String, dynamic>> excercicios; // exercícios
  final String title; // título

  const WorkoutPagePersonalizado({super.key, required this.excercicios, required this.title});

  @override
  _WorkoutPagePersonalizadoState createState() => _WorkoutPagePersonalizadoState();
}

class _WorkoutPagePersonalizadoState extends State<WorkoutPagePersonalizado> with SingleTickerProviderStateMixin  {
  int currentExerciseIndex = 0; // index do exercício atual
  bool isTimerRunning = false; // tempo rodando? 
  Timer? _countdownTimer; // diminui o tempo
  Duration _remainingTime = Duration(minutes: 1); // tempo restante
  Duration timerDuration = Duration(minutes: 1); // duração
  late AnimationController _pulseController; // controle de animação de pulso
  late Animation<double> _pulseAnimation; //  animação de pulos
  late final AudioPlayer _audioPlayer; // player de audio

  // ativa e desativa o timer 
  void toggleTimer() {
  setState(() {
    isTimerRunning = !isTimerRunning;
  });

  if (isTimerRunning) {
    _pulseController.repeat(reverse: true); // 👉 começa a pulsar
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        _pulseController.stop(); // 👉 para de pulsar quando acaba
        _pulseController.value = 1.0;
        completeSet();
        _audioPlayer.play(AssetSource('sounds/retro_game.mp3'));
        setState(() {
          isTimerRunning = false;
        });
      }
    });
  } else {
    _pulseController.stop(); // 👉 para de pulsar ao pausar
    _pulseController.value = 1.0; // reseta para escala normal
    _countdownTimer?.cancel();
  }
}

  // vai para o próximo exercício
  void nextExercise() {
  if (currentExerciseIndex < widget.excercicios.length - 1) {
    setState(() {
      currentExerciseIndex++;
      isTimerRunning = false;
      _countdownTimer?.cancel();
      
      int durationInMinutes = widget.excercicios[currentExerciseIndex]['duration'];
      timerDuration = Duration(minutes: durationInMinutes);
      _remainingTime = timerDuration;
    });

    _pulseController.stop();
  }
}
  // volta para o exercício anterior
  void previousExercise() {
  if (currentExerciseIndex > 0) {
    setState(() {
      currentExerciseIndex--;
      isTimerRunning = false;
      _countdownTimer?.cancel();

      int durationInMinutes = widget.excercicios[currentExerciseIndex]['duration'];
      timerDuration = Duration(minutes: durationInMinutes);
      _remainingTime = timerDuration;
    });

    _pulseController.stop();
  }
}

 // completa um set
  void completeSet() async {
  final exercise = widget.excercicios[currentExerciseIndex];

  setState(() {
    exercise['completedSets']++;

    if (exercise['completedSets'] >= exercise['sets']) {
      exercise['completed'] = true;
      widget.excercicios.removeAt(currentExerciseIndex);

      if (currentExerciseIndex >= widget.excercicios.length) {
        currentExerciseIndex = widget.excercicios.length - 1;
      }

      if (widget.excercicios.isEmpty) {
        AppDataService.salvarTudo();
         AppData.ativoHoje = true;
        AppData.atualizarDailyStats(treinoConcluido: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WorkoutCompletePage()),
        );
        return;
      }
    }

    // Atualiza o exercício atual e reinicia o timer
    if (widget.excercicios.isNotEmpty) {
      final nextExercise = widget.excercicios[currentExerciseIndex];
      timerDuration = Duration(minutes: nextExercise['duration']);
      _remainingTime = timerDuration;

      // Só reinicia automaticamente se ainda tem sets pra esse exercício
      if (nextExercise['completedSets'] < nextExercise['sets']) {
        isTimerRunning = false; // espera o usuário clicar de novo
        _pulseController.stop();
        _pulseController.value = 1.0;
        _countdownTimer?.cancel();
      }
    }
  });

  await AppDataService.salvarTudo();
}


  @override
void dispose() {
  _countdownTimer?.cancel();
  _pulseController.dispose();
  super.dispose();
}

  @override
void initState() {
  super.initState();

  if (widget.excercicios.isNotEmpty) {
    var currentExercise = widget.excercicios[currentExerciseIndex];
    int durationInMinutes = currentExercise['duration'];
    timerDuration = Duration(minutes: durationInMinutes);
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

  @override
  Widget build(BuildContext context) {
    bool isWarning = _remainingTime <= Duration(minutes: 1);
    if (widget.excercicios.isEmpty) {
  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: 
    Center(
      child: Text(
        "Você concluiu todos os exercícios! 🎉",
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
    var currentExercise = widget.excercicios[currentExerciseIndex];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("${widget.title}", style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 30.0,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                )),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${currentExercise['name']}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            SizedBox(height: 10),
            Text("${currentExercise['sets']} sets", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4))),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Clique para descansar", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4))),
            ],),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: toggleTimer,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isWarning ? Colors.redAccent : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(currentExercise['sets'], (index) {
                return IconButton(
                  icon: Icon(
                    index < currentExercise['completedSets'] ? Icons.check_circle : Icons.radio_button_unchecked,
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
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
                  onPressed: previousExercise,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Theme.of(context).textTheme.bodyLarge?.color),
                  onPressed: nextExercise,
                ),
              ],
            ),
          SizedBox(height: 100,)
          ],
        ),
      ),
    );
  }
}
