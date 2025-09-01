import 'package:flutter/material.dart';
import 'dart:async';

// timer da pagina de treino
class WorkoutTimer extends StatefulWidget {
  final int duration; // Tempo total em segundos

  const WorkoutTimer({super.key, required this.duration});

  @override
  _WorkoutTimerState createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  late int _remainingTime;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
  }

  void _startTimer() {
    if (_timer != null) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = widget.duration;
      _timer = null;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              onPressed: _isRunning ? _pauseTimer : _startTimer,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetTimer,
            ),
          ],
        ),
      ],
    );
  }
}