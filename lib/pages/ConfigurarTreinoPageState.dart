
import 'package:flutter/material.dart';
import '../app_data.dart';
import '../main.dart';
import '../models/TreinoModel.dart';
import '../services/VerificarAgendamento.dart';

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

  void _salvarTreino() async{
  AppData.treinos.add(TreinoModel(nome: nomeTreino, diasSemana: formatar_dia(diasSelecionados), exercicios: List.from(AppData.treinosSelecionados), horario: horarioSelecionado as TimeOfDay, intensidade: intensidadeSelecionada));
  AppData.treinosSelecionados.clear();
  await AppData.salvarDados();
  await Verificaragendamento.verficarAgendamento();
  if (!mounted) return;
  Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
  }

  @override
  Widget build(BuildContext context) {
    final bool configurandoTreino =
        indexAtual < AppData.treinosSelecionados.length;


    return Scaffold(
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: Text("Configurar Treino", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Navegação
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
                      style:  TextStyle(
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

              // Conteúdo dinâmico
              if (configurandoTreino) ...[
                Text("Sets:", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20)),
                DropdownButton<int>(
                  value: AppData.treinosSelecionados[indexAtual].sets,
                  elevation: 0,
                  dropdownColor: Theme.of(context).primaryColor,
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
                SizedBox(height: 5,),
                Text("Duração do Descanso (min):", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20)),
                TextField(
                style:  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'Duração (min): ',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    try {
                      AppData.treinosSelecionados[indexAtual].duration = int.parse(value);
                      erroMensagem = null; // limpa erro se deu certo
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
                Spacer(),
              ] else ...[
                // Última tela: horário e dias
                ListTile(
                  title: Text("Selecionar Horário", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,  fontSize: 20)),
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
                const SizedBox(height: 10),
                TextField(
                style:  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,  fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Nome do Treino',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    nomeTreino = value;
                  });
                },
              ),
              SizedBox(height: 30,),
                Text("Dias da Semana", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,  fontSize: 20)),
                Wrap(
                  spacing: 8.0,
                  children: diasDaSemana.map((dia) {
                    final selecionado = diasSelecionados.contains(dia);
                    return ChoiceChip(
                      label: Text(dia),
                      selected: selecionado,
                      selectedColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8, blue: 0.1, green: 0.6, red: 0.7),
                      backgroundColor: Theme.of(context).primaryColor,
                      checkmarkColor: Theme.of(context).scaffoldBackgroundColor,
                      labelStyle:
                          TextStyle(color: selecionado ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyLarge?.color),
                      onSelected: (_) => _toggleDia(dia),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                Text("Intensidade", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20)),
                DropdownButton<int>(
  value: intensidadeSelecionada,
  elevation: 0,
  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
  items: [
    DropdownMenuItem(
      value: 3,
      child: Text(
        "Força (Até 6 repetições)",
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    ),
    DropdownMenuItem(
      value: 2,
      child: Text(
        "Hipertrofia (Até 12 repetições)",
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    ),
    DropdownMenuItem(
      value: 1,
      child: Text(
        "Perda de Gordura (Até 18 repetições)",
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    ),
  ],
  onChanged: (value) {
    setState(() {
      intensidadeSelecionada = value!;
    });
  },
),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _salvarTreino();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Treino salvo com sucesso!")),
                    );
                  },
                  icon:  Icon(Icons.check, color: Theme.of(context).scaffoldBackgroundColor,),
                  label:  Text("Salvar Treino", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
                ),
                Spacer(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
