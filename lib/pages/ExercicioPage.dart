import 'package:flutter/material.dart';
import '../app_data.dart';
import '../models/ExercicioModel.dart';
import '../pages/ConfigurarTreinoPageState.dart';
import '../app_data_service.dart';



class ExerciciosPage extends StatefulWidget {
  final String categoria;
  final List<String> exercicios;

  const ExerciciosPage({required this.categoria, required this.exercicios, super.key});

  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  final Map<String, bool> _selecionados = {};

  @override
  void initState() {
    super.initState();
    for (var exercicio in widget.exercicios) {
      _selecionados[exercicio] = false;
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

  @override
  Widget build(BuildContext context) {
    bool algumSelecionado = AppData.treinosSelecionados.isNotEmpty;

    bool isSelecionado(String exercicio) {
  return AppData.treinosSelecionados.any((e) => e.name == exercicio);
}

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria, style: TextStyle(fontSize: 25, fontWeight:FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: ListView(
        children: widget.exercicios.map((exercicio) {
          return Padding(padding: EdgeInsets.all(10),
          child: Card(
            elevation: 0,
            color: Theme.of(context).scaffoldBackgroundColor,
            child:
            Column(children: [
              SizedBox(height: 1,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.rectangle, // ou BoxShape.circle pra deixar redondo
                borderRadius: BorderRadius.circular(12), // só funciona se for rectangle
                border: Border.all(color: const Color.fromARGB(0, 255, 153, 0), width: 2),
                ),
                child: Row(
                children: [
                  Checkbox(
                    value: isSelecionado(exercicio),
                    onChanged: (bool? value) {
                      if (value == true) {
                        if (!isSelecionado(exercicio)) {
                          AppData.treinosSelecionados.add(
                            ExercicioModel(name: exercicio, sets: 1, duration: 1),
                          );
                        }
                      } else {
                        AppData.treinosSelecionados.removeWhere((e) => e.name == exercicio);
                      }
                      setState(() {});
                    },
                    activeColor: Theme.of(context).colorScheme.secondary,
                    checkColor: Theme.of(context).scaffoldBackgroundColor,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4,), // muda a borda sem Theme!
                      width: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    exercicio,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                    ),
                  ),)
                ],
              ),
              ),
            ],) 
          ),); 
        }).toList(),
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
