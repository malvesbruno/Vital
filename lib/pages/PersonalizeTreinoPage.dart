import 'package:flutter/material.dart';
import 'WorkoutPagePersonalizada.dart';
import 'dart:ui' as ui;
import '../app_data_service.dart';


class PersonalizeTreinoPage extends StatefulWidget{
  const PersonalizeTreinoPage({super.key});

  @override 
  State<PersonalizeTreinoPage> createState() => _PersonalizeTreinoPageState(); 
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

class _PersonalizeTreinoPageState extends State<PersonalizeTreinoPage>{
  final excercicios = [
  {'name': 'Polichinelo', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Agachamento com salto', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Flexão de braço', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Prancha', 'duration': 3, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Corrida no lugar', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Burpee', 'duration': 2, 'sets': 1, 'completedSets': 0, 'escolhido': false},
  {'name': 'Mountain Climbers', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Superman', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Afundo alternado', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Abdominal completo', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Flexão de braço', 'duration': 2, 'sets': 3, 'completedSets': 0, 'escolhido': false},
  {'name': 'Tríceps no chão', 'duration': 2, 'sets': 3, 'completedSets': 0, 'escolhido': false},
  {'name': 'Flexão diamante', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Pulsos cruzados', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Superman com braços', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Alcance alternado', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Abdominal canivete', 'duration': 2, 'sets': 3, 'completedSets': 0, 'escolhido': false},
  {'name': 'Prancha cotovelo', 'duration': 3, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Abdominal bicicleta', 'duration': 2, 'sets': 3, 'completedSets': 0, 'escolhido': false},
  {'name': 'Elevação de pernas', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Russian Twist', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Abdominal lateral', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Agachamento', 'duration': 2, 'sets': 3, 'completedSets': 0, 'escolhido': false},
  {'name': 'Afundo', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Elevação de panturrilha', 'duration': 1, 'sets': 3, 'completedSets': 0, 'escolhido': false},
  {'name': 'Agachamento com salto', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Ponte de glúteo', 'duration': 2, 'sets': 3, 'completedSets': 0, 'escolhido': false},
  {'name': 'Chute para trás', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Sumô Squat', 'duration': 2, 'sets': 2, 'completedSets': 0, 'escolhido': false},
  {'name': 'Lateral step', 'duration': 1, 'sets': 2, 'completedSets': 0, 'escolhido': false},
];

  List<Map<String, dynamic>> lista = [];
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
          "Treino Rápido",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Expanded(
  child: ListView.builder(
    itemCount: excercicios.length,
    itemBuilder: (context, index) {
      return buildCard(index);
    },
  ),
),

            ),
            SizedBox(height: 10,),
            SizedBox(
            width: 300, // largura desejada
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutPagePersonalizado(
              title: "Seu Treino",
              excercicios: lista,
            ),
          ),
        ); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const ui.Size(double.infinity, 50),
              ),
              child: Text('Ir para Treino', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),),
            ),
          ),
          SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }


  Widget buildCard(int index) {
    final exercicio = excercicios[index];
    String title = exercicio['name'] as String;
    Duration duracao = Duration(minutes: exercicio['duration'] as int);
    bool escolhido = exercicio['escolhido'] as bool;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: InkWell(
      onTap: () { },
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16), // Padding reduzido
          child: Row(
            children: [
              // Imagem com tamanho fixo // Espaçamento
              Expanded( // Garante que o texto não cause overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 18, // Tamanho reduzido
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Trunca texto longo
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDuration(duracao)} min',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16, // Tamanho reduzido
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: 60,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() async{
                      excercicios[index]['escolhido'] = !escolhido;

                      if (excercicios[index]['escolhido'] as bool) {
                        lista.add(exercicio);
                      } else {
                        lista.removeWhere((e) => e['name'] == exercicio['name']);
                      }
                      await AppDataService.salvarTudo();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: escolhido? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12), // Espaçamento interno pro ícone ficar no centro
                    minimumSize:  const ui.Size(50, 50), // Tamanho fixo do botão
                  ),
                  child: Icon(Icons.check, size: 30, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),

              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}