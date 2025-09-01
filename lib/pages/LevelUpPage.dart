import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';


// Level Up Page
class LevelUpPage extends StatefulWidget {
  final int newLevel;
  final List<String> unlockedItems;

  const LevelUpPage({required this.newLevel, required this.unlockedItems, super.key});

  @override
  State<LevelUpPage> createState() => _LevelUpPageState();
}

class _LevelUpPageState extends State<LevelUpPage> {
  late ConfettiController _confettiController; //váriavel de confetti
  final AudioPlayer _audioPlayer = AudioPlayer(); // variável que toca áudios

  @override
  void initState() {
    super.initState();
    // configura o confetti
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    // toca áudios 
    _playVictorySound();
  }

  void _playVictorySound() async {
    await _audioPlayer.play(AssetSource('sounds/levelUp.mp3'));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.02,
            numberOfParticles: 10,
            gravity: 0.2,
            colors: const [
              Color.fromRGBO(255, 165, 0, 0.4), // Laranja translúcido
              Color.fromRGBO(255, 255, 255, 0.3), // Branco translúcido
              Color.fromRGBO(255, 255, 0, 0.4), // Amarelo translúcido
            ],
            minimumSize: const Size(5, 5),
            maximumSize: const Size(10, 10),
            shouldLoop: false,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🎉 Level Up!",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.orange.shade300,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.orange.shade900,
                          blurRadius: 20,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Você chegou ao nível ${widget.newLevel}!",
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  if (widget.unlockedItems.isNotEmpty)
                    Column(
                      children: [
                        const Text(
                          "Desbloqueou:",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(widget.unlockedItems[0], style: TextStyle(fontSize: 20, color: Colors.white)),
                        CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage(widget.unlockedItems[1]), // substitua pelo avatar atual do usuário
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      ],
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Continuar", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

