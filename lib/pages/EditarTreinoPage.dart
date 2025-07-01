import 'package:flutter/material.dart';
import '../app_data.dart';
import '../main.dart';
import '../models/TreinoModel.dart';
import '../app_data_service.dart';
import '../cloud_service.dart';
import 'dart:convert';


class EditarTreinoPage extends StatefulWidget {
  final TreinoModel treino;

  const EditarTreinoPage({super.key, required this.treino});

  @override
  State<EditarTreinoPage> createState() => _EditarTreinoPageState();
}

class _EditarTreinoPageState extends State<EditarTreinoPage> {
  int indexAtual = 0;
  TimeOfDay? horarioSelecionado;
  List<String> diasSelecionados = [];
  String nomeTreino = '';
  bool erro = false;
  String? erroMensagem;
  

  final List<String> diasDaSemana = [
    "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"
  ];

  @override
  void initState() {
    super.initState();
    nomeTreino = widget.treino.nome;
    diasSelecionados = desformatarDias(widget.treino.diasSemana);
    AppData.treinosSelecionados = List.from(widget.treino.exercicios);
    horarioSelecionado = widget.treino.horario;
  }

  List<String> desformatarDias(List<int> numeros) {
    Map<int, String> mapa = {
      1: "Seg",
      2: "Ter",
      3: "Qua",
      4: "Qui",
      5: "Sex",
      6: "Sáb",
      7: "Dom"
    };
    return numeros.map((n) => mapa[n] ?? "").where((e) => e.isNotEmpty).toList();
  }

  List<int> formatarDias(List<String> lista) {
    Map<String, int> mapaDias = {
      "Seg": 1, "Ter": 2, "Qua": 3, "Qui": 4, "Sex": 5, "Sáb": 6, "Dom": 7
    };
    return lista.map((el) => mapaDias[el] ?? 0).where((el) => el != 0).toList();
  }

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

  void _salvarEdicao() async{
    widget.treino.nome = nomeTreino;
    widget.treino.diasSemana = formatarDias(diasSelecionados);
    widget.treino.exercicios = List.from(AppData.treinosSelecionados);
    widget.treino.horario = horarioSelecionado as TimeOfDay;
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage())); // volta para tela anterior
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Treino editado com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool configurandoTreino =
        indexAtual < AppData.treinosSelecionados.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Treino", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge?.color),
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
                  icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.bodyLarge?.color),
                  onPressed: _proximo,
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (configurandoTreino) ...[
              Text("Sets:", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20)),
              DropdownButton<int>(
                value: AppData.treinosSelecionados[indexAtual].sets,
                elevation: 0,
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                onChanged: (int? value) {
                  setState(() {
                    AppData.treinosSelecionados[indexAtual].sets = value!;
                  });
                },
                items: List.generate(10, (i) => i + 1)
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text('$e', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ))
                    .toList(),
              ),
              Text("Duração (min):", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20)),
              TextField(
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration:  InputDecoration(
                  labelText: 'Duração (min): ',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    try {
                      AppData.treinosSelecionados[indexAtual].duration = int.parse(value);
                      erroMensagem = null;
                    } catch (_) {
                      erroMensagem = 'O texto deve ser um número inteiro.';
                    }
                  });
                },
              ),
              if (erroMensagem != null)
                Text(erroMensagem!, style: const TextStyle(color: Colors.red)),
              Spacer(),
            ] else ...[
              ListTile(
                title: Text("Selecionar Horário", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                subtitle: Text(
                  horarioSelecionado != null
                      ? "${horarioSelecionado!.hour.toString().padLeft(2, '0')}:${horarioSelecionado!.minute.toString().padLeft(2, '0')}"
                      : "Nenhum horário selecionado",
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.access_time, color: Theme.of(context).textTheme.bodyLarge?.color),
                  onPressed: _selecionarHorario,
                ),
              ),
              TextField(
                style:  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration:  InputDecoration(
                  labelText: 'Nome do Treino',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                controller: TextEditingController(text: nomeTreino),
                onChanged: (value) => nomeTreino = value,
              ),
              const SizedBox(height: 30),
              Text("Dias da Semana", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              Wrap(
                spacing: 8.0,
                children: diasDaSemana.map((dia) {
                  final selecionado = diasSelecionados.contains(dia);
                  return ChoiceChip(
                    label: Text(dia),
                    selected: selecionado,
                    selectedColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8, blue: 0.1, green: 0.6, red: 0.7),
                    checkmarkColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(color: selecionado ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyLarge?.color),
                    onSelected: (_) => _toggleDia(dia),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _salvarEdicao,
                icon:  Icon(Icons.save, color: Theme.of(context).scaffoldBackgroundColor),
                label: Text("Salvar Alterações", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
              ),
              Spacer(),
            ]
          ],
        ),
      ),
    );
  }
}
