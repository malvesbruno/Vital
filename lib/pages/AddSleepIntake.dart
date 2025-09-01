import 'package:flutter/material.dart';
import '../app_data.dart';
import '../app_data_service.dart';


// pagina que auxilia na saude do sono
class AddSleepIntakePage extends StatefulWidget {
  const AddSleepIntakePage({super.key});

  @override
  State<AddSleepIntakePage> createState() => _AddSleepIntakePageState();
}


class _AddSleepIntakePageState extends State<AddSleepIntakePage>{
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          "Sono",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(child: 
      Center(
        child: Column(
          children: [
              buildCard('2', 2),
              buildCard('4', 4),
              buildCard('6', 6),
              buildCard('8', 8),
              buildCard('10', 10),
              buildCard('12', 12),
              buildCardPersonalizado(),

            ],)
        ),)
      );
  }


  Widget buildCard(String text, double value) {
  return Padding(
    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
    child: InkWell(
      onTap: () async{
        AppData.horasDormidas += value;
        AppData.ativoHoje = true;
        AppData.atualizarDailyStats(horasDormidas: value);
        await AppDataService.salvarTudo();
        if (!mounted) return;
        Navigator.pop(context, true);
},
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Row(
            children: [
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$text horas dormidas',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildCardPersonalizado() {
  return Padding(
    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
    child: InkWell(
      onTap: () {
  showDialog(
    context: context,
    builder: (context) {
      double? customHours;
      return AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Quantidade Personalizada", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: "Digite o número de horas",
            hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          onChanged: (value) {
            customHours = double.tryParse(value);
          },
        ),
        actions: [
          TextButton(
            child: Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Adicionar", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            onPressed: () {
              if (customHours != null && customHours! > 0) {
                AppData.horasDormidas += customHours!;
                AppData.ativoHoje = true;
                AppData.atualizarDailyStats(horasDormidas: customHours?.toDouble());
                Navigator.pop(context); // Fecha o dialog
                Navigator.pop(context, true); // Volta para a tela anterior
              }
            },
          ),
        ],
      );
    },
  );
},
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Row(
            children: [
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicione a Quantidade Exata',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
