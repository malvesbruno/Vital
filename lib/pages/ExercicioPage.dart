import 'package:flutter/material.dart';
import '../app_data.dart';
import '../models/ExercicioModel.dart';
import '../pages/ConfigurarTreinoPageState.dart';
import '../app_data_service.dart';



class ExerciciosPage extends StatefulWidget {
  final String categoria;
  final Map<String, List<String>> exercicios;

  const ExerciciosPage({required this.categoria, required this.exercicios, super.key});

  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  final Map<String, bool> _selecionados = {};

  @override
  void initState() {
    super.initState();
    for (var subgrupo in widget.exercicios.values) {
      for (var exercicio in subgrupo) {
        _selecionados[exercicio] = false;
      }
    }
  }

  void _confirmarSelecionados() async{
    AppData.treinosSelecionados.addAll(
      _selecionados.entries
          .where((entry) => entry.value)
          .map((entry) => 
          ExercicioModel(name: entry.key, sets: 1, duration: 1))
          .toList(),
    );


    await AppDataService.salvarTudo();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfigurarTreinoPage()),
    );
  }

  Widget _buildExercicioTile(String exercicio) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Checkbox(
              value: AppData.treinosSelecionados.any((e) => e.name == exercicio),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    if (!_selecionados.containsKey(exercicio)) {
                      _selecionados[exercicio] = true;
                    }
                    AppData.treinosSelecionados.add(
                      ExercicioModel(name: exercicio, sets: 1, duration: 1),
                    );
                  } else {
                    AppData.treinosSelecionados.removeWhere((e) => e.name == exercicio);
                    _selecionados[exercicio] = false;
                  }
                });
              },
              activeColor: Theme.of(context).colorScheme.secondary,
              checkColor: Theme.of(context).scaffoldBackgroundColor,
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary.withAlpha(100),
                width: 2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                exercicio,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _mostrarDialogoNovoExercicio() {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text("Novo exercício", style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Nome do exercício', fillColor: Theme.of(context).textTheme.bodyLarge?.color, iconColor: Theme.of(context).textTheme.bodyLarge?.color, hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
        ),
        TextButton(
          onPressed: () {
            final nome = controller.text.trim();
            if (nome.isNotEmpty) {
              setState(() {
                _selecionados[nome] = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Treino ${nome} adicionado com sucesso')),
                );
              });
              Navigator.pop(context);
            }
          },
          child: Text('Adicionar', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    bool algumSelecionado = _selecionados.values.any((v) => v) || AppData.treinosSelecionados.isNotEmpty;

    bool isSelecionado(String exercicio) {
  return AppData.treinosSelecionados.any((e) => e.name == exercicio);
}

    return Scaffold(
      appBar: AppBar(
        title: Text("Adicione outro grupo muscular", style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: ListView(
  children:
    [
   ...widget.exercicios.entries.map((entry) {
    final subgrupo = entry.key;
    final exercicios = entry.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(subgrupo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...exercicios.map((exercicio) => _buildExercicioTile(exercicio)).toList(),
      ],
    );
  }).toList(),
  SizedBox(height: 20,),
  ElevatedButton.icon(
  onPressed: _mostrarDialogoNovoExercicio,
  icon: Icon(Icons.add),
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
    foregroundColor: MaterialStateProperty.all(Theme.of(context).scaffoldBackgroundColor),

  ),
  label: Text('Adicionar exercício personalizado'),
),
SizedBox(height: 50,)
    ]
),
      floatingActionButton: algumSelecionado
          ? FloatingActionButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // arredondado como padrão
            side:  BorderSide(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 0,
            ),
          ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: _confirmarSelecionados,
              child:  Icon(Icons.navigate_next, color: Theme.of(context).scaffoldBackgroundColor,),
            )
          : null,
    );
  }
}
