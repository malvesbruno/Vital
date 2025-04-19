import '../models/AtividadeModel.dart';
import 'package:flutter/material.dart';
import '../app_data.dart';
import '../services/VerificarAgendamento.dart';

class AddActivityPage extends StatefulWidget {
  final Function(AtividadeModel) onAdd;

  const AddActivityPage({super.key, required this.onAdd});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _titleController = TextEditingController();
  String? _categoriaSelecionada;
  TimeOfDay? _horarioSelecionado;
  List<int> diasSelecionados = [];

  final List<int> diasDaSemana = [1,2,3,4,5,6,7];

  void _selecionarHorario() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _horarioSelecionado = time);
    }
  }

  bool isHojeNaLista(List<int> diasDaSemana) {
  int weekday = DateTime.now().weekday;
  return diasDaSemana.contains(weekday);
}

  void _updateProgressBar() {
    final atividadesHoje = AppData.listaAtividades.where((el) => isHojeNaLista(el.dias));
    if (atividadesHoje.isEmpty){
      AppData.progress = 0;
    }

    final concluidas = atividadesHoje.where((el) => el.completed).length;
    AppData.progress = concluidas / atividadesHoje.length;

  }

  void _salvarAtividade() async{
    if (_titleController.text.isEmpty || _categoriaSelecionada == null || _horarioSelecionado == null || diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final novaAtividade = AtividadeModel(title: _titleController.text, categoria: _categoriaSelecionada as String, horario: _horarioSelecionado as TimeOfDay, dias: diasSelecionados, completed: false);

    widget.onAdd(novaAtividade);
    _updateProgressBar();
    await AppData.salvarDados();
    await Verificaragendamento.verficarAgendamento();
    if (!mounted) return;
    Navigator.pop(context);
  }

  String DiaSemana(int id){
    switch (id){
      case(1):{
        return 'Segunda';
      }
      case(2):{
        return 'Terça';
      }
      case(3):{
        return 'Quarta';
      }
      case(4):{
        return 'Quinta';
      }
      case(5):{
        return 'Sexta';
      }
      case(6):{
        return 'Sábado';
      }
      case(7):{
        return 'Domingo';
      }
      default:{
        return "Segunda";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
      appBar: AppBar(
        title: const Text('Nova Atividade', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Nome da Atividade',
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 20),

              // Categoria
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                ),
                items: AppData.categorias.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _categoriaSelecionada = val);
                },
              ),
              const SizedBox(height: 20),

              // Horário
              Row(
                children: [
                  const Text('Horário:', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    _horarioSelecionado?.format(context) ?? 'Selecione',
                    style: const TextStyle(color: Colors.tealAccent, fontSize: 20),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _selecionarHorario,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text('Escolher', style: TextStyle(color: Colors.white),),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Dias da semana
              const Text('Dias da Semana:', style: TextStyle(color: Colors.white, fontSize: 16)),
              Wrap(
                spacing: 8,
                children: diasDaSemana.map((dia) {
                  final selecionado = diasSelecionados.contains(dia);
                  return FilterChip(
                    label: Text(DiaSemana(dia), style: TextStyle(color: selecionado ? Color.fromARGB(255, 0, 0, 0) : Colors.white),),
                    labelStyle: TextStyle(color: selecionado ? Colors.black : Colors.white,),
                    selected: selecionado,
                    selectedColor: Colors.tealAccent,
                    backgroundColor: const Color.fromARGB(255, 101, 101, 101),
                    onSelected: (_) {
                      setState(() {
                        if (selecionado) {
                          diasSelecionados.remove(dia);
                        } else {
                          diasSelecionados.add(dia);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Botão de salvar
              Center(
                child: ElevatedButton(
                  onPressed: _salvarAtividade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Salvar Atividade', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
