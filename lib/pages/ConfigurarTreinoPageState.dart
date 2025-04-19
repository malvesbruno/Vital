
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
  AppData.treinos.add(TreinoModel(nome: nomeTreino, diasSemana: formatar_dia(diasSelecionados), exercicios: List.from(AppData.treinosSelecionados), horario: horarioSelecionado as TimeOfDay));
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
      appBar: AppBar(
        title: const Text("Configurar Treino", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _anterior,
                  ),
                  Expanded(
                    child: Text(
                      configurandoTreino
                          ? AppData.treinosSelecionados[indexAtual].name
                          : 'Agendamento',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _proximo,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Conteúdo dinâmico
              if (configurandoTreino) ...[
                const Text("Sets:", style: TextStyle(color: Colors.white, fontSize: 20)),
                DropdownButton<int>(
                  value: AppData.treinosSelecionados[indexAtual].sets,
                  elevation: 0,
                  dropdownColor: const Color.fromARGB(255, 31, 31, 31),
                  onChanged: (int? value) {
                    setState(() {
                      AppData.treinosSelecionados[indexAtual].sets = value!;
                    });
                  },
                  items: List.generate(10, (i) => i + 1)
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text('$e', style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                ),
                SizedBox(height: 5,),
                const Text("Duração (min):", style: TextStyle(color: Colors.white, fontSize: 20)),
                TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Duração (min): ',
                  labelStyle: TextStyle(color: Colors.white),
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
                  title: const Text("Selecionar Horário", style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    horarioSelecionado != null
                        ? "${horarioSelecionado!.hour.toString().padLeft(2, '0')}:${horarioSelecionado!.minute.toString().padLeft(2, '0')}"
                        : "Nenhum horário selecionado",
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time, color: Colors.white),
                    onPressed: _selecionarHorario,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome do Treino',
                  labelStyle: TextStyle(color: Colors.white),
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
                const Text("Dias da Semana", style: TextStyle(color: Colors.white)),
                Wrap(
                  spacing: 8.0,
                  children: diasDaSemana.map((dia) {
                    final selecionado = diasSelecionados.contains(dia);
                    return ChoiceChip(
                      label: Text(dia),
                      selected: selecionado,
                      selectedColor: const Color.fromARGB(255, 210, 210, 210),
                      backgroundColor: Colors.grey[800],
                      labelStyle:
                          TextStyle(color: selecionado ? Colors.black : Colors.white),
                      onSelected: (_) => _toggleDia(dia),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 210, 210, 210),
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
                  icon: const Icon(Icons.check, color: Color.fromARGB(255, 0, 0, 0),),
                  label: const Text("Salvar Treino", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),),
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
