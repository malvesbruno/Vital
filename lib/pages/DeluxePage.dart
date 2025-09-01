import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../widgets/deluxeAvataresPreview.dart';
import '../widgets/deluxeThemePreview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../pages/SignUpPage.dart';
import '../pages/LogInPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../in_app_purchase.dart';
import '../app_data.dart';
import '../app_data_service.dart';
import '../cloud_service.dart';
import '../pages/MyHomePage.dart';


// Tela que permite a compra de planos

class Deluxepage extends StatefulWidget{
  const Deluxepage({super.key});

  @override
  State<Deluxepage> createState() => _DeluxePageState();
}

class _DeluxePageState extends State<Deluxepage>{
    late InAppPurchaseService _purchaseService; // váriavel da compra in-app
  bool _isLoading = false; // está carregando

  @override
  void initState() {
    super.initState();
    _purchaseService = InAppPurchaseService();
    _initializePurchaseService();
  }

  // inicia o compra in-app
  Future<void> _initializePurchaseService() async {
    await _purchaseService.initialize();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  // comprar produto 
  Future<void> _purchaseProduct(String productId) async {
  setState(() => _isLoading = true);
  
  try {
    // Carrega os produtos disponíveis
    final products = await _purchaseService.loadProducts();
    
    // Encontra o produto específico que o usuário quer comprar
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Produto não encontrado')
    );
    
    // Realiza a compra
    await _purchaseService.buyProduct(product);
    
    // Verifica se a compra foi bem sucedida
    final hasActive = await _purchaseService.hasActivePurchase();
    if (hasActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra realizada com sucesso!')),
      );
      // Aqui você pode liberar os recursos premium
      try{
      AppData.ultimate = true;
      await AppDataService.salvarTudo();
      final user = FirebaseAuth.instance.currentUser;
       final treinosJson = AppData.treinos.map((t) => t.toJson()).toList();
       final atividadeJson = AppData.listaAtividades.map((t) => t.toJson()).toList();
       final statsJson = AppData.historicoStats.map((t) => t.toJson()).toList();
       final amigosJson = AppData.amigos.map((t) => t.toJson()).toList();
       final themesOwnedJson = AppData.themes.where((t) => t.owned).map((el) => el.toJson()).toList();
       final avatarsOwnedJson = AppData.themes.where((t) => t.owned).map((el) => el.toJson()).toList();
      BackupService cloud = BackupService();
          await cloud.createUser(AppData.id, {
            'mail': user?.email ?? '',
            'uid': AppData.id,
            'treinos': jsonEncode(treinosJson),
            'atividades': jsonEncode(atividadeJson),
            'stats': jsonEncode(statsJson),
            'amigos': jsonEncode(amigosJson),
            'current_avatar': AppData.currentAvatar,
            'current_theme': AppData.currentTheme,
            'temas_comprados': jsonEncode(themesOwnedJson),
            'avatares_comprados': jsonEncode(avatarsOwnedJson),
            'data_compra': DateTime.now().toIso8601String(),
            'nivel': AppData.level,
            'coins': AppData.coins,
            'plano': productId,
          });
          Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()), // Substitua pelo nome real da sua tela inicial
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no Banco de Dados: ${e.toString()}')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro na compra: ${e.toString()}')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  //verifica se tem um plano ativo
  Future<void> _checkActiveSubscription() async {
  final hasActive = await _purchaseService.hasActivePurchase();
  if (hasActive) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você já tem uma assinatura ativa!')),
    );
    // Aqui você pode redirecionar para a tela premium ou liberar os recursos
  }
}


    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Deluxe'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escolha um plano para ter acesso aos benefícios',
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: ()async{
                final user = FirebaseAuth.instance.currentUser;
                if (user == null){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen())); 
                } else{
                  await _checkActiveSubscription();
                }

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary, // Cor de fundo // Cor do texto/ícone
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text('Já tem um plano ativo? Faça LogIn', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
            ),
            SizedBox(height: 16),

            _PlanCard(
            title: 'Mensal',
            price: 'R\$14,90 / mês',
            description: 'Acesso total enquanto estiver ativo.',
            isUtimate: false,
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
              } else {
                await _purchaseProduct('premium_acess_month');
              }
            },
          ),

          _PlanCard(
            title: 'Anual',
            price: 'R\$99,90 / ano',
            description: 'Acesso total enquanto estiver ativo.',
            isUtimate: true,
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
              } else {
                await _purchaseProduct('premium_acess');
              }
            },
          ),

          _PlanCard(
            title: 'Vitalício',
            price: 'R\$179,90',
            description: 'Acesso permanente',
            isUtimate: true,
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
              } else {
                await _purchaseProduct('vitalicio');
              }
            },
          ),

          _isLoading ? BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ) : SizedBox(height: 1,),

            const SizedBox(height: 32),
            cardBenefits(),
            SizedBox(height: 50,)
          ],
        ),
      ),
      )
    );    
  }
}

class cardBenefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: EdgeInsets.all(20),
      child:  Column(
        children: [
          Card(color: Theme.of(context).colorScheme.secondary,
          child: 
          Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Text(
              'Assinantes Deluxe desbloqueiam:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),)
          ),
            const SizedBox(height: 10),
            Card(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2),
          child: 
          Padding(padding: EdgeInsets.all(10),
          child: 
          Row(children: [
            Icon(FontAwesomeIcons.plus, color: Theme.of(context).textTheme.bodyLarge?.color,),
            Spacer(),
            Text(
              'Multiplicador de Moedas e XP',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            Spacer()
          ],))
          ),
            const SizedBox(height: 10),
            Card(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2),
          child: 
          Padding(padding: EdgeInsets.all(10),
          child: 
          Column(children: [
            Row(children: [
            Icon(FontAwesomeIcons.users, color: Theme.of(context).textTheme.bodyLarge?.color,),
            Spacer(),
            Text(
              'Avatares e temas Especiais',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            Spacer()
          ],),
          DeluxeAvatarsPreview(),
          DeluxeThemePreview(),
          ],)
          )
          ),
            const SizedBox(height: 10),
            Card(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2),
          child: 
          Padding(padding: EdgeInsets.all(10),
          child: 
          Row(children: [
            Icon(FontAwesomeIcons.cloud, color: Theme.of(context).textTheme.bodyLarge?.color,),
            Spacer(),
            Text(
              'Backup em Núvem',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            Spacer()
          ],))
          ),
            const SizedBox(height: 10),
            Card(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2),
          child: 
          Padding(padding: EdgeInsets.all(10),
          child: 
          Row(children: [
            Icon(FontAwesomeIcons.shoePrints, color: Theme.of(context).textTheme.bodyLarge?.color,),
            Spacer(),
            Text(
              'Contador de Passos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            Spacer()
          ],))
          ),
          const SizedBox(height: 10),
          Card(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2),
          child: 
          Padding(padding: EdgeInsets.all(10),
          child: 
          Row(children: [
            Icon(FontAwesomeIcons.chartSimple, color: Theme.of(context).textTheme.bodyLarge?.color,),
            Spacer(),
            Text(
              'Acompanhamentos\n dos útimos 30 dias',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            Spacer()
          ],))
          ),
            const SizedBox(height: 10),
            Card(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2),
          child: 
          Padding(padding: EdgeInsets.all(10),
          child: 
          Row(children: [
            Icon(FontAwesomeIcons.userGroup, color: Theme.of(context).textTheme.bodyLarge?.color,),
            Spacer(),
            Text(
              'Adicionar amigos\ne acompanhar ranking',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            Spacer()
          ],))
          ),
            const SizedBox(height: 10),
            Card(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.2),
          child: 
          Padding(padding: EdgeInsets.all(10),
          child: 
          Row(children: [
            Icon(FontAwesomeIcons.ban, color: Theme.of(context).textTheme.bodyLarge?.color,),
            Spacer(),
            Text(
              'Bloqueador de Anúncios',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            Spacer()
          ],))
          ),
            const SizedBox(height: 10),
        ],
      ),)
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final VoidCallback onTap;
  final bool isUtimate;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.onTap,
    required this.isUtimate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Theme.of(context).colorScheme.secondary,
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 8),
              Text(price, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary)),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),),
            ],
          ),
        ),
      ),
    );
  }
}