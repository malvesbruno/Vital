import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vital/models/AmigoModel.dart';
import 'package:vital/models/AvatarModel.dart';
import 'package:vital/models/ColorsModel.dart';
import '../pages/DeluxePage.dart';
import '../cloud_service.dart';
import 'dart:convert';
import '../app_data.dart';
import '../models/TreinoModel.dart';
import '../models/AtividadeModel.dart';
import '../models/DailyStatsModel.dart';
import '../app_data_service.dart';


class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  void _logIn() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário logado com sucesso!')),
    );

    BackupService cloud = BackupService();
    final user_info = await cloud.getUserByEmail(userCredential.user?.email ?? '');

    if (user_info == null) throw Exception('Dados do usuário não encontrados.');

    DateTime dataConvertida = DateTime.parse(user_info['data_compra']);
    final agora = DateTime.now();
    final diferenca = agora.difference(dataConvertida);

    bool temAcesso = false;
    final plano = user_info['plano'];

    if (plano == 'mensal' && diferenca.inDays <= 37) temAcesso = true;
    if (plano == 'anual' && diferenca.inDays <= 379) temAcesso = true;
    if (plano == 'vitalicio') temAcesso = true;

    if (temAcesso) {
      AppData.ultimate = true;
      AppData.id = user_info['uid'];
      AppData.currentAvatar = user_info['current_avatar'] ?? "Default";
      AppData.currentTheme = user_info['current_theme'] ?? "Default";
      AppData.level = user_info['nivel'] ?? 1;
      AppData.coins = user_info['coins'] ?? 0;
      AppData.name = user_info['name'] ?? 'Deafult_Name';

      // Helpers para parse de lista JSON ou lista direta
      List<dynamic> parseList(dynamic data) {
        if (data is String) return jsonDecode(data);
        if (data == '') return [];
        return data ?? [];
      }

      AppData.treinos = parseList(user_info['treinos'])
          .map((t) => TreinoModel.fromJson(t))
          .toList();

      AppData.listaAtividades = parseList(user_info['atividades'])
          .map((a) => AtividadeModel.fromJson(a))
          .toList();

      AppData.historicoStats = parseList(user_info['stats'])
          .map((s) => DailyStats.fromJson(s))
          .toList();

      AppData.amigos = parseList(user_info['amigos'])
          .map((a) => AmigoModel.fromJson(a))
          .toList();

      final temasComprados = parseList(user_info['temas_comprados'])
          .map((t) => AppTheme.fromJson(t))
          .toList();

      final avataresComprados = parseList(user_info['avatares_comprados'])
          .map((a) => AvatarModel.fromJson(a))
          .toList();

      final nomesTemasComprados = temasComprados.map((t) => t.name).toSet();
      final nomesAvataresComprados = avataresComprados.map((a) => a.name).toSet();

      for (var tema in AppData.themes) {
        if (nomesTemasComprados.contains(tema.name)) {
          tema.owned = true;
        }
      }

      for (var avatar in AppData.avatars) {
        if (nomesAvataresComprados.contains(avatar.name)) {
          avatar.owned = true;
        }
      }

      AppDataService.salvarTudo();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Deluxepage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plano expirado ou inválido.')),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String message = 'Erro ao fazer login. Tente novamente.';
    switch (e.code) {
      case 'user-not-found':
        message = 'Usuário não encontrado.';
        break;
      case 'wrong-password':
        message = 'Senha incorreta.';
        break;
      case 'invalid-email':
        message = 'Email inválido.';
        break;
      case 'user-disabled':
        message = 'Esta conta foi desativada.';
        break;
      case 'too-many-requests':
        message = 'Muitas tentativas. Tente mais tarde.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro desconhecido: ${e.toString()}')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Email', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 25),),
          SizedBox(height: 10,),
            TextField(
              style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
              controller: _emailController,
              cursorColor: Theme.of(context).colorScheme.secondary,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
              hintText: 'Digite seu Email',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2.0),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 245, 245, 245),
            ),
            ),
            SizedBox(height: 30,),
            Text('Senha', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 25),),
            SizedBox(height: 10,),
            TextField(
              style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
              controller: _passwordController,
              cursorColor: Theme.of(context).colorScheme.secondary,
              obscureText: true,
              decoration: InputDecoration(
              hintText: 'Digite sua Senha',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2.0),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 245, 245, 245),
            ),

            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _logIn,
                    style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary, // Cor de fundo // Cor do texto/ícone
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
                    child:  Text('LogIn', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 20),),
                  ),
          ],
        ),
      ),
    );
  }
}
