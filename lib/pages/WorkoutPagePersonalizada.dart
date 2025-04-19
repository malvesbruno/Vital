import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../app_data.dart';
import 'WorkoutComplete.dart';

class WorkoutPagePersonalizado extends StatefulWidget {
  final List<Map<String, dynamic>> excercicios;
  final String title;

  const WorkoutPagePersonalizado({super.key, required this.excercicios, required this.title});

  @override
  _WorkoutPagePersonalizadoState createState() => _WorkoutPagePersonalizadoState();
}

class _WorkoutPagePersonalizadoState extends State<WorkoutPagePersonalizado> with SingleTickerProviderStateMixin  {
  int currentExerciseIndex = 0;
  bool isTimerRunning = false;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration(minutes: 1);
  Duration timerDuration = Duration(minutes: 1);
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late final AudioPlayer _audioPlayer;

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


  void completeSet() async {
  setState(() {
    var exercise = widget.excercicios[currentExerciseIndex];
    exercise['completedSets']++;

    if (exercise['completedSets'] >= exercise['sets']) {
      AppData.treinosDiarios++;
      widget.excercicios.removeAt(currentExerciseIndex);

      if (currentExerciseIndex >= widget.excercicios.length) {
        currentExerciseIndex = widget.excercicios.length - 1;
      }

      if (widget.excercicios.isEmpty) {
        // Salva antes de sair
        AppData.salvarDados(); // sem await no setState
        AppData.atualizarDailyStats(treinoConcluido: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WorkoutCompletePage()),
        );
        return;
      }

      int durationInMinutes = widget.excercicios[currentExerciseIndex]['duration'];
      timerDuration = Duration(minutes: durationInMinutes);
      _remainingTime = timerDuration;

      _countdownTimer?.cancel();
      isTimerRunning = false;
    }
  });

  // Garante persistência fora do setState
  await AppData.salvarDados();
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
    backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
    body: 
    Center(
      child: Text(
        "Você concluiu todos os exercícios! 🎉",
        style: TextStyle(color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
    var currentExercise = widget.excercicios[currentExerciseIndex];
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("${widget.title}", style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                )),
        backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${currentExercise['name']}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            Text("${currentExercise['sets']} sets", style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 20),
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
                      color: Colors.grey[900],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isWarning ? Colors.redAccent : Colors.white,
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
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: previousExercise,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
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
