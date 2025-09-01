import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/DeluxePage.dart';


// SignUp Page
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController(); // váriavel de input de email
  final _passwordController = TextEditingController(); // váriavel de input de senha
  bool _isLoading = false; // carregando 
  final _auth = FirebaseAuth.instance; // instância a firebase


  // faz signup
  void _signup() async {
  setState(() {
    _isLoading = true;  // carregando 
  });

  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final user = userCredential.user;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário criado com sucesso!')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => Deluxepage()));


  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String message = 'Erro desconhecido.';
    if (e.code == 'email-already-in-use') {
      message = 'Email já está em uso.';
    } else if (e.code == 'invalid-email') {
      message = 'Email inválido.';
    } else if (e.code == 'weak-password') {
      message = 'Senha fraca. Use no mínimo 6 caracteres.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } finally {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
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
      appBar: AppBar(title: const Text('Criar conta'),
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
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary, // Cor de fundo // Cor do texto/ícone
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
                    child:  Text('Cadastrar', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 20),),
                  ),
          ],
        ),
      ),
    );
  }
}
