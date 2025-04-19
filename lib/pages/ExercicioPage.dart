import 'package:flutter/material.dart';
import '../app_data.dart';
import '../models/ExercicioModel.dart';
import '../pages/ConfigurarTreinoPageState.dart';


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

    await AppData.salvarDados();
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
        title: Text(widget.categoria, style: TextStyle(fontSize: 25, fontWeight:FontWeight.bold),),
        backgroundColor: const Color.fromARGB(0, 31, 31, 31),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: widget.exercicios.map((exercicio) {
          return Padding(padding: EdgeInsets.all(10),
          child: Card(
            elevation: 0,
            color: const Color.fromARGB(255, 31, 31, 31),
            child:
            Column(children: [
              SizedBox(height: 10,),
              CheckboxListTile(
                  title: Text(
                    exercicio,
                    style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 20), // Cor do texto
                  ),
                  activeColor: const Color.fromARGB(255, 131, 131, 131), // Cor do checkbox marcado
                  checkColor: Colors.white,   // Cor do check (✓)
                  tileColor: const Color.fromARGB(255, 31, 31, 31), // Cor de fundo do tile (desde o Flutter 3.7+)
                  value: isSelecionado(exercicio),
                  onChanged:  (bool? value) {
                      if (value == true) {
                        if (!isSelecionado(exercicio)) {
                          AppData.treinosSelecionados.add(
                            ExercicioModel(name: exercicio, sets: 1, duration: 1));
                        }
                      } else {
                        AppData.treinosSelecionados.removeWhere((e) => e.name == exercicio);
                      }

                      setState(() {});
                    },
                ),
            SizedBox(height: 10,),
            ],) 
          ),); 
        }).toList(),
      ),
      floatingActionButton: algumSelecionado
          ? FloatingActionButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // arredondado como padrão
            side: const BorderSide(
              color: Color.fromARGB(209, 79, 79, 79),
              width: 2,
            ),
          ),
            backgroundColor: const Color.fromARGB(255, 31, 31, 31),
              onPressed: _confirmarSelecionados,
              child: const Icon(Icons.navigate_next, color: Colors.white,),
            )
          : null,
    );
  }
}
