import 'package:flutter/material.dart';
import '../app_data.dart';


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
        backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: const Text(
          "Sono",
          style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),
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


  Widget buildCard(String text, int value) {
  return Padding(
    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
    child: InkWell(
      onTap: () async{
        AppData.horasDormidas += value;
        await AppData.salvarDados();
        if (!mounted) return;
        Navigator.pop(context, true);
},
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: const Color.fromARGB(255, 31, 31, 31),
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
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        title: Text("Quantidade Personalizada", style: TextStyle(color: Colors.white)),
        content: TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Digite o número de horas",
            hintStyle: TextStyle(color: Colors.white54),
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
            child: Text("Adicionar", style: TextStyle(color: Colors.tealAccent)),
            onPressed: () {
              if (customHours != null && customHours! > 0) {
                AppData.horasDormidas += customHours!;
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
        color: const Color.fromARGB(255, 31, 31, 31),
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
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
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
