import 'package:flutter/material.dart';
import '../app_data.dart';
import '../models/AtividadeModel.dart';
import '../services/challenge_service.dart';

class AddRemdyIntakePage extends StatefulWidget {
  const AddRemdyIntakePage({super.key});

  @override
  State<AddRemdyIntakePage> createState() => _AddRemedyIntakePageState();
}

String timeOfDayToString(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class _AddRemedyIntakePageState extends State<AddRemdyIntakePage>{
  
  bool isHojeNaLista(List<int> diasDaSemana) {
  int weekday = DateTime.now().weekday;
  return diasDaSemana.contains(weekday);
}

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
          "VitalTrack",
          style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
        child: Column(
          children: [
            ...AppData.listaAtividades
    .where((el) => el.categoria == 'Saúde' && !el.completed && isHojeNaLista(el.dias))
    .map((el) => buildCard(el))
    .toList(),
            ],)
        ),
      )
      );
  }


  Widget buildCard(AtividadeModel remedio) {
  return Padding(
    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
    child: InkWell(
      onTap: () async {  // Move async here, outside of setState
        remedio.completed = true;
        await AppData.salvarDados();
        ChallengeService.verificarDesafiosAutomaticos();  // First do the async work
        setState(() {  // Then update the state synchronously
          // Any state updates would go here
          // Though in this case, we're modifying the object directly
          // so we might not need anything here
        });
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
                    remedio.title,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timeOfDayToString(remedio.horario),
                    style: TextStyle(color: const Color.fromARGB(255, 119, 119, 119), fontSize: 15, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
}