import 'package:flutter/material.dart';
import '../pages/WorkoutPagePersonalizada.dart';
import '../pages/PersonalizeTreinoPage.dart';


//Menu de treino rápido
class SetTreinoRapidoPage extends StatefulWidget {
  const SetTreinoRapidoPage({super.key});

  @override
  State<SetTreinoRapidoPage> createState() => _SetTreinoRapidoPageState();
}

class _SetTreinoRapidoPageState extends State<SetTreinoRapidoPage>{
  // 🟥 Exercícios para Corpo inteiro
  final corpoInteiroExercises = [
  {'name': 'Polichinelo', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Agachamento com salto', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Flexão de braço', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Prancha', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Corrida no lugar', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Burpee', 'duration': 1, 'sets': 1, 'completedSets': 0},
  {'name': 'Mountain Climbers', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Superman', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Afundo alternado', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Abdominal completo', 'duration': 1, 'sets': 2, 'completedSets': 0},
];
// 🟥 Exercícios para Peito
  final bracosExercises = [
  {'name': 'Flexão de braço', 'duration': 1, 'sets': 3, 'completedSets': 0},
  {'name': 'Tríceps no chão', 'duration': 1, 'sets': 3, 'completedSets': 0},
  {'name': 'Flexão diamante', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Pulsos cruzados', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Superman com braços', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Alcance alternado', 'duration': 1, 'sets': 2, 'completedSets': 0},
];
// 🟥 Exercícios para Abdomen
  final abdomenExercises = [
  {'name': 'Abdominal canivete', 'duration': 1, 'sets': 3, 'completedSets': 0},
  {'name': 'Prancha cotovelo', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Abdominal bicicleta', 'duration': 1, 'sets': 3, 'completedSets': 0},
  {'name': 'Elevação de pernas', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Russian Twist', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Abdominal lateral', 'duration': 1, 'sets': 2, 'completedSets': 0},
];
// 🟥 Exercícios para Perna
  final pernasExercises = [
  {'name': 'Agachamento', 'duration': 1, 'sets': 3, 'completedSets': 0},
  {'name': 'Afundo', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Elevação de panturrilha', 'duration': 1, 'sets': 3, 'completedSets': 0},
  {'name': 'Agachamento com salto', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Ponte de glúteo', 'duration': 1, 'sets': 3, 'completedSets': 0},
  {'name': 'Chute para trás', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Sumô Squat', 'duration': 1, 'sets': 2, 'completedSets': 0},
  {'name': 'Lateral step', 'duration': 1, 'sets': 2, 'completedSets': 0},
];

  // transforma o dia em String
  String timeOfDayToString(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
  
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
            buildCard('Corpo Inteiro', 10, Image.asset('assets/images/corpo_inteiro.png'), false, corpoInteiroExercises),
            buildCard('Braços', 6, Image.asset('assets/images/braços.png'), false, bracosExercises),
            buildCard('Abdômen', 6, Image.asset('assets/images/abdomen.png'), false, abdomenExercises),
            buildCard('Pernas', 8, Image.asset('assets/images/pernas.png'), false, pernasExercises),
            buildCard('Monte seu Treino', 0, Image.asset('assets/images/personalizado.png'), true, []),
          ],
        ),
      ),
    );
  }


  Widget buildCard(String title, int qtd, Image image, bool personalizado, List<Map<String, dynamic>> lista) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: InkWell(
      onTap: () {
        !personalizado? Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutPagePersonalizado(
              title: title,
              excercicios: lista,
            ),
          ),
        ) : Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalizeTreinoPage(),
          ),
        );

      },
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16), // Padding reduzido
          child: Row(
            children: [
              // Imagem com tamanho fixo
              SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: image,
                ),
              ),
              const SizedBox(width: 16), // Espaçamento
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
                      !personalizado? '$qtd excercícios': '',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16, // Tamanho reduzido
                      ),
                    ),
                  ],
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
