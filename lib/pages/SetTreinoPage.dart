import 'package:flutter/material.dart';
import '../app_data.dart';
import 'ExercicioPage.dart';
import 'ConfigurarTreinoPageState.dart';

class SetTreinoPage extends StatefulWidget {
  const SetTreinoPage({super.key});

  @override
  State<SetTreinoPage> createState() => _SetTreinoPageState();
}

class _SetTreinoPageState extends State<SetTreinoPage>{
  // 🟥 Exercícios para Peito
final Map<String, List<String>> chestExercises = {
  'Peitoral': [
    'Supino reto com barra',
    'Supino reto com halteres',
    'Supino inclinado com halteres',
    'Crucifixo reto com halteres',
    'Crucifixo inclinado com halteres',
    'Crossover no cabo',
    'Flexão com peso nas costas',
    'Flexão usando halteres como apoio',
    'Supino declinado com barra',
    'Pressão de peito na máquina',
  ]
};

final Map<String, List<String>> backExercises = {
  'Costas': [
    'Pulley frente',
    'Remada baixa',
    'Remada unilateral com halteres',
    'Remada curvada com barra',
    'Puxada na barra guiada',
    'Levantamento terra com barra',
    'Remada cavalinho (T-bar)',
    'Encolhimento de ombros com halteres',
    'Pull-over com halteres',
    'Barra fixa (assistida ou não)',
  ]
};

final Map<String, List<String>> armExercises = {
  'Bíceps': [
    'Rosca direta com barra',
    'Rosca martelo com halteres',
    'Rosca alternada com halteres',
    'Rosca Scott na máquina',
    'Rosca concentrada',
    'Rosca no cabo',
  ],
  'Tríceps': [
    'Tríceps testa com barra EZ',
    'Tríceps pulley',
    'Tríceps banco com peso no colo',
    'Tríceps francês com halteres',
  ]
};

final Map<String, List<String>> absExercises = {
  'Abdômen': [
    'Abdominal na máquina',
    'Abdominal com anilha no peito',
    'Elevação de pernas na barra fixa',
    'Abdominal oblíquo com halteres',
    'Prancha com peso nas costas',
    'Flexão de tronco ajoelhado na polia alta',
    'Russian twist com anilha',
    'Prancha com remada unilateral',
    'Canivete com anilha',
    'Rollout com roda abdominal',
  ]
};

final Map<String, List<String>> legExercises = {
  'Pernas': [
    'Agachamento com barra',
    'Agachamento com halteres',
    'Afundo com halteres',
    'Leg press',
    'Cadeira extensora',
    'Mesa flexora',
    'Elevação de panturrilha em máquina',
    'Stiff com halteres',
    'Step-up com halteres',
    'Agachamento búlgaro com halteres',
  ]
};

  bool algumSelecionado = AppData.treinosSelecionados.isNotEmpty;


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
            AppData.treinosSelecionados.clear();
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Treino",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            buildCard('Peito', chestExercises.values
  .map((lista) => lista.length)
  .fold(0, (a, b) => a + b), Image.asset('assets/images/peito.png'), false, chestExercises),
            buildCard('Costas', backExercises.values
  .map((lista) => lista.length)
  .fold(0, (a, b) => a + b), Image.asset('assets/images/costas.png'), false, backExercises),
            buildCard('Braços', armExercises.values
  .map((lista) => lista.length)
  .fold(0, (a, b) => a + b), Image.asset('assets/images/braços.png'), false, armExercises),
            buildCard('Abdômen', absExercises.values
  .map((lista) => lista.length)
  .fold(0, (a, b) => a + b), Image.asset('assets/images/abdomen.png'), false, absExercises),
            buildCard('Pernas', legExercises.values
  .map((lista) => lista.length)
  .fold(0, (a, b) => a + b), Image.asset('assets/images/pernas.png'), false, legExercises),
            
          ],
        ),
      ),
      floatingActionButton: algumSelecionado
    ? FloatingActionButton(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ConfigurarTreinoPage()),
          );
        },
        shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20), // arredondado como padrão
    side: const BorderSide(
      color: Color.fromARGB(209, 79, 79, 79),
      width: 2,
    ),
  ),
        child:  Icon(Icons.navigate_next, color: Theme.of(context).textTheme.bodyLarge?.color),
      )
    : null,
    );
  }


  Widget buildCard(String title, int qtd, Image image, bool personalizado, Map<String, List<String>> lista) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: InkWell(
      onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciciosPage(categoria: title, exercicios: lista)));
      },
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color:  Theme.of(context).primaryColor,
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