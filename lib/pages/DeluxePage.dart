import 'dart:ui';

import 'package:flutter/material.dart';
import '../widgets/deluxeAvataresPreview.dart';
import '../widgets/deluxeThemePreview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Deluxepage extends StatefulWidget{
  const Deluxepage({super.key});

  @override
  State<Deluxepage> createState() => _DeluxePageState();
}

class _DeluxePageState extends State<Deluxepage>{
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
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            _PlanCard(
              title: 'Mensal',
              price: 'R\$14,90 / mês',
              description: 'Acesso total enquanto estiver ativo.',
              isUtimate: false,
              onTap: () {
                // TODO: Integrar com sistema de pagamento mensal
              },
            ),
            const SizedBox(height: 16),

            _PlanCard(
              title: 'Anual',
              price: 'R\$99,90 / ano',
              description: 'Acesso total enquanto estiver ativo.',
              isUtimate: true,
              onTap: () {
                // TODO: Integrar com sistema de pagamento único
              },
            ),
            const SizedBox(height: 16),

            _PlanCard(
              title: 'Vitalício',
              price: 'R\$179,90',
              description: 'Acesso permanente + 2 avatares épicos exclusivos!',
              isUtimate: true,
              onTap: () {
                // TODO: Integrar com sistema de pagamento único
              },
            ),
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