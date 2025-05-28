// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../main.dart'; // ou '../pages/MainPage.dart', conforme organização
import '../app_data.dart';
import '../app_data_service.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    
    _startApp();
  }

  Future<void> _startApp() async {
    try {
      await Future.delayed(const Duration(seconds: 5)); // mostra a animação por 2s mínimo

      await AppDataService.carregarTudo();
      await AppData.verificarSePrecisaSalvarHoje();
      await AppData.carregarDesafiosDoDia();
      await AppData.loadOwnedAvatars();
      await AppData.loadOwnedColors();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao iniciar o app: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/launch.json', width: 200, repeat: true),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              )
            else
              const Text(
                "Carregando Vital...",
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
