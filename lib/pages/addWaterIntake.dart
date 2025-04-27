import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_data.dart';
import '../services/challenge_service.dart';


class AddWaterIntakePage extends StatefulWidget {
  const AddWaterIntakePage({super.key});

  @override
  State<AddWaterIntakePage> createState() => _AddWaterIntakePageState();
}

class _AddWaterIntakePageState extends State<AddWaterIntakePage>{
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Consumo de Água",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            buildCard('200 mL', 200, FontAwesomeIcons.droplet),
            buildCard('500 mL', 500, FontAwesomeIcons.glassWater),
            buildCard('1 L', 1000, FontAwesomeIcons.bottleWater),
            buildCard('2 L', 2000, FontAwesomeIcons.jugDetergent)
          ],
        ),
      ),
    );
  }


  Widget buildCard(String title, int value, IconData icone){
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, top: 10),
      child: InkWell(
        onTap: () async{
          AppData.waterConsumed += value;
          AppData.atualizarDailyStats(agua: value.toDouble());
          ChallengeService.verificarDesafiosAutomaticos();
          await AppData.salvarDados();
    if (!mounted) return;
          Navigator.pop(context, true);
        }, // ação ao tocar no card
        borderRadius: BorderRadius.circular(10),
        child: Card(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Row(
              children: [
                Icon(icone, size: 30, color: Theme.of(context).textTheme.bodyLarge?.color),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}