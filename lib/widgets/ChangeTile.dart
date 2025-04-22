import 'package:flutter/material.dart';
import '../app_data.dart';
import '../models/DailyChallenge.dart';
import 'package:audioplayers/audioplayers.dart';

class ChallengeTile extends StatefulWidget {
  final DailyChallengeModel challenge;
  final VoidCallback onCoinsChanged;
  const ChallengeTile(this.challenge, {required this.onCoinsChanged, super.key});

  @override
  State<ChallengeTile> createState() => _ChallengeTileState();
}

class _ChallengeTileState extends State<ChallengeTile> {
    final AudioPlayer _audioPlayer = AudioPlayer();
    
    @override
    void initState() {
      super.initState();
      _audioPlayer.setVolume(1.0); // Agora está num lugar válido!
    }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        widget.challenge.completed ? Icons.check_circle : Icons.circle_outlined,
        color: widget.challenge.completed ? Colors.green : Colors.grey,
        size: 28,
      ),
      title: Text(
        widget.challenge.title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Montserrat',
          decoration: widget.challenge.completed ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: () async {
  final wasCompleted = widget.challenge.completed; // Guarda o estado anterior
  
  setState(() {
    widget.challenge.completed = !wasCompleted; // Inverte o estado
    if (widget.challenge.completed) {
      AppData.coins += widget.challenge.reward;
    } else {
      AppData.coins -= widget.challenge.reward;
    }
  });

  try {
    await _audioPlayer.stop(); // Para qualquer som anterior
    
    if (widget.challenge.completed) {
      await _audioPlayer.play(AssetSource('sounds/coinUp.mp3'));
      print("[DEBUG] Desafio completado! EXP a adicionar: ${widget.challenge.exp}"); // ✅
      AppData.addExperience(context, widget.challenge.exp); // ⚠️ Garantido que será chamado
    } else {
      await _audioPlayer.play(AssetSource('sounds/coinDown.mp3'));
      print("[DEBUG] Desafio desmarcado! EXP a remover: ${widget.challenge.exp}"); // ✅
      AppData.addExperience(context, -widget.challenge.exp); // Remove o EXP
    }
    AppData.salvarDados();
  } catch (e) {
    print("[ERRO] Ao reproduzir áudio: $e"); // Se o áudio falhar, não bloqueia o EXP
    if (widget.challenge.completed) {
      AppData.addExperience(context, widget.challenge.exp); // Fallback
    }
  }

  widget.onCoinsChanged(); // Atualiza a UI
},
    );
  }
}
