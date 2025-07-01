import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

class StepCounterPage extends StatefulWidget {
  const StepCounterPage({super.key});

  @override
  State<StepCounterPage> createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  int _dailySteps = 0;
  int _stepsAtMidnight = 0;
  late Stream<StepCount> _stepCountStream;
  DateTime _lastSavedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (await Permission.activityRecognition.request().isGranted) {
      final prefs = await SharedPreferences.getInstance();
      _stepsAtMidnight = prefs.getInt('stepsAtMidnight') ?? 0;
      String? savedDate = prefs.getString('lastSavedDate');

      // Checa se a data mudou
      if (savedDate == null || savedDate != _formattedDate(DateTime.now())) {
        prefs.setString('lastSavedDate', _formattedDate(DateTime.now()));
        _stepsAtMidnight = 0;
        prefs.setInt('stepsAtMidnight', 0);
      }

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen((event) => onStepCount(event, prefs)).onError(onStepCountError);
    } else {
      print("Permissão negada para reconhecimento de atividade.");
    }
  }

  void onStepCount(StepCount event, SharedPreferences prefs) {
  int currentSteps = event.steps;
  DateTime now = DateTime.now();
  String today = _formattedDate(now);
  String? savedDate = prefs.getString('lastSavedDate');

  if (savedDate == null || savedDate != today) {
    // É um novo dia ou ainda não há data salva
    prefs.setString('lastSavedDate', today);
    prefs.setInt('lastKnownSteps', event.steps);
    prefs.setInt('stepsAtMidnight', currentSteps);
    _stepsAtMidnight = currentSteps;

    print("Novo dia detectado. stepsAtMidnight atualizado para $currentSteps");
  } else {
    // Atualiza _stepsAtMidnight com o que está salvo, se ainda não tiver sido carregado
    if (_stepsAtMidnight == 0 && prefs.containsKey('stepsAtMidnight')) {
      _stepsAtMidnight = prefs.getInt('stepsAtMidnight')!;
    }
  }

  setState(() {
    _dailySteps = currentSteps - _stepsAtMidnight;
  });

  print("Passos totais: $currentSteps | Base: $_stepsAtMidnight | Hoje: $_dailySteps");
}

  void onStepCountError(error) {
    print('Erro ao obter contagem de passos: $error');
  }

  String _formattedDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  void _checkDateChange() async {
  final prefs = await SharedPreferences.getInstance();
  String today = _formattedDate(DateTime.now());
  String? savedDate = prefs.getString('lastSavedDate');

  if (savedDate != today) {
    int lastStep = prefs.getInt('lastKnownSteps') ?? 0;
    prefs.setString('lastSavedDate', today);
    prefs.setInt('stepsAtMidnight', lastStep);
    setState(() {
      _stepsAtMidnight = lastStep;
      _dailySteps = 0;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    _checkDateChange();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.shoePrints, color: Theme.of(context).textTheme.bodyLarge?.color, size: 30.0),
                  const SizedBox(width: 20),
                  Text('Passos Hoje', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25, fontFamily: 'Montserrat')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('$_dailySteps', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 40, fontFamily: 'Montserrat')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
