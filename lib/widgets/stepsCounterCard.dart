import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StepCounterPage extends StatefulWidget {
  const StepCounterPage({super.key});

  @override
  State<StepCounterPage> createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  int _steps = 0;
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Solicitar permissão no Android
    if (await Permission.activityRecognition.request().isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(onStepCount).onError(onStepCountError);
    } else {
      print("Permissão negada para reconhecimento de atividade.");
    }
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
    });
  }

  void onStepCountError(error) {
    print('Erro ao obter contagem de passos: $error');
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Passos Dados', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25, fontFamily: 'Montserrat')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('$_steps', style:  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 40, fontFamily: 'Montserrat')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}