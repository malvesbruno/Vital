
import 'package:flutter/material.dart';
import '../app_data.dart';
import '../main.dart';
import '../models/TreinoModel.dart';
import '../app_data_service.dart';
import '../cloud_service.dart';
import 'dart:convert';


class ConfigurarTreinoPage extends StatefulWidget {
  const ConfigurarTreinoPage({super.key});

  @override
  State<ConfigurarTreinoPage> createState() => _ConfigurarTreinoPageState();
}

class _ConfigurarTreinoPageState extends State<ConfigurarTreinoPage> {
  int indexAtual = 0;
  TimeOfDay? horarioSelecionado;
  List<String> diasSelecionados = [];
  String nomeTreino = '';
  bool erro = false;
  String? erroMensagem;
  int intensidadeSelecionada = 1;

  final List<String> diasDaSemana = [
    "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"
  ];

  void _toggleDia(String dia) {
    setState(() {
      if (diasSelecionados.contains(dia)) {
        diasSelecionados.remove(dia);
      } else {
        diasSelecionados.add(dia);
      }
    });
  }

  void _selecionarHorario() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        horarioSelecionado = picked;
      });
    }
  }

  void _anterior() {
    if (indexAtual > 0) {
      setState(() {
        indexAtual--;
      });
    }
  }

  void _proximo() {
    if (indexAtual < AppData.treinosSelecionados.length) {
      setState(() {
        indexAtual++;
      });
    }
  }

  List<int> formatar_dia(List<String> lista){
    Map<String, int> mapaDias = {
      "Seg": 1, "Segunda": 1,
      "Ter": 2, "Terça": 2,
      "Qua": 3, "Quarta" :3,
      "Qui": 4, "Quinta":4,
      "Sex":5, "Sexta":5,
      "Sáb":6, "Sábado":6,
      "Dom":7, "Domingo":7
    };
    return lista.map((el) => mapaDias[el] ?? 0).where((el) => el != 0).toList();
  }

  void _salvarTreino() async {
  if (horarioSelecionado == null) return;

  AppData.treinos.add(
    TreinoModel(
      nome: nomeTreino,
      diasSemana: formatar_dia(diasSelecionados),
      exercicios: List.from(AppData.treinosSelecionados),
      horario: horarioSelecionado!,
      intensidade: intensidadeSelecionada,
    ),
  );
  AppData.treinosSelecionados.clear();
  if (AppData.ultimate){
        final treinosJson = AppData.treinos.map((t) => t.toJson()).toList();
        final statsJson = AppData.historicoStats.map((t) => t.toJson()).toList();
        BackupService cloud = BackupService();
        await cloud.updateUser(AppData.id, {
          'treinos': jsonEncode(treinosJson),
          'stats': jsonEncode(statsJson),
          'current_avatar': AppData.currentAvatar,
          'current_theme': AppData.currentTheme,
          'nivel': AppData.level,
          'coins': AppData.coins,
        });
      }
  await AppDataService.salvarTudo();
  if (!mounted) return;
  Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
}

  @override
  Widget build(BuildContext context) {
    final bool configurandoTreino =
        indexAtual < AppData.treinosSelecionados.length;
    final Set<int> modificadosSets = {};
    final Set<int> modificadosDuracoes = {};


    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Configurar Treino",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Navegação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      onPressed: _anterior,
                    ),
                    Expanded(
                      child: Text(
                        configurandoTreino
                            ? AppData.treinosSelecionados[indexAtual].name
                            : 'Agendamento',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 24,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      onPressed: _proximo,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                if (configurandoTreino) ...[
                  Text("Sets:",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 20)),
                  DropdownButton<int>(
                    value: AppData.treinosSelecionados[indexAtual].sets,
                    elevation: 0,
                    dropdownColor: Theme.of(context).primaryColor,
                    onChanged: (int? value) {
                    setState(() {
                      AppData.treinosSelecionados[indexAtual].sets = value!;
                      if (indexAtual == 0) {
                        for (int i = 1; i < AppData.treinosSelecionados.length; i++) {
                          if (!modificadosSets.contains(i)) {
                            AppData.treinosSelecionados[i].sets = value;
                          }
                        }
                      } else {
                        modificadosSets.add(indexAtual);
                      }
                    });
                  },
                    items: List.generate(10, (i) => i + 1)
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text('$e',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).textTheme.bodyLarge?.color)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 5),
                  Text("Duração do Descanso (min):",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 20)),
                  TextField(
                    style:
                        TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      labelText: 'Duração (min): ',
                      labelStyle:
                          TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                    setState(() {
                      try {
                        int duracao = int.parse(value);
                        AppData.treinosSelecionados[indexAtual].duration = duracao;
                        if (indexAtual == 0) {
                          for (int i = 1; i < AppData.treinosSelecionados.length; i++) {
                            if (!modificadosDuracoes.contains(i)) {
                              AppData.treinosSelecionados[i].duration = duracao;
                            }
                          }
                        } else {
                          modificadosDuracoes.add(indexAtual);
                        }
                        erroMensagem = null;
                      } catch (e) {
                        erroMensagem = 'O texto deve ser um número inteiro, ex: "20"';
                      }
                    });
                  },

                  ),
                  if (erroMensagem != null)
                    Text(
                      erroMensagem!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),

                  const SizedBox(height: 20),
                ] else ...[
                  // Última tela: horário e dias
                  ListTile(
                    title: Text("Selecionar Horário",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 20)),
                    subtitle: Text(
                      horarioSelecionado != null
                          ? "${horarioSelecionado!.hour.toString().padLeft(2, '0')}:${horarioSelecionado!.minute.toString().padLeft(2, '0')}"
                          : "Nenhum horário selecionado",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.access_time,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      onPressed: _selecionarHorario,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style:
                        TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    decoration: InputDecoration(
                      labelText: 'Nome do Treino',
                      labelStyle:
                          TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        nomeTreino = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  Text("Dias da Semana",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 20)),
                  Wrap(
                    spacing: 8.0,
                    children: diasDaSemana.map((dia) {
                      final selecionado = diasSelecionados.contains(dia);
                      return ChoiceChip(
                        label: Text(dia),
                        selected: selecionado,
                        selectedColor:
                            Theme.of(context).colorScheme.secondary.withAlpha(200),
                        backgroundColor: Theme.of(context).primaryColor,
                        checkmarkColor: Theme.of(context).scaffoldBackgroundColor,
                        labelStyle: TextStyle(
                            color: selecionado
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).textTheme.bodyLarge?.color),
                        onSelected: (_) => _toggleDia(dia),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  Text("Intensidade",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 20)),
                  DropdownButton<int>(
                    value: intensidadeSelecionada,
                    elevation: 0,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    items: [
                      DropdownMenuItem(
                        value: 3,
                        child: Text(
                          "Força (Até 6 repetições)",
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          "Hipertrofia (Até 12 repetições)",
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          "Perda de Gordura (Até 18 repetições)",
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        intensidadeSelecionada = value!;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 30),

                if (!configurandoTreino)
                ElevatedButton(
                  onPressed: _salvarTreino,
                  child: Text(
                    'Salvar',
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor, fontSize: 22),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
