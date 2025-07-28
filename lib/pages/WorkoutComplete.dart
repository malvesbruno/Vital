import 'package:flutter/material.dart';
import '../main.dart';
import 'dart:ui' as ui;

class WorkoutCompletePage extends StatelessWidget {
  const WorkoutCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: Theme.of(context).textTheme.bodyLarge?.color, size: 100),
              SizedBox(height: 20),
              Text(
                "Parabéns!\nVocê concluiu seu treino 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()), // substitua pelo nome da sua home
                    (Route<dynamic> route) => false,
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const ui.Size(double.infinity, 50),
                ),
                child: Text("Voltar ao início", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
