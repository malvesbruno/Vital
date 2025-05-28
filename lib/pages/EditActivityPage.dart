import 'package:flutter/material.dart';
import '../app_data.dart';
import '../main.dart';
import '../models/AtividadeModel.dart';
import '../app_data_service.dart';


class EditActivityPage extends StatefulWidget {
  final int index;


  const EditActivityPage({super.key, required this.index,});

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _titleController = TextEditingController();
  String? _categoriaSelecionada;
  TimeOfDay? _horarioSelecionado;
  List<int> diasSelecionados = [];

  final List<int> diasDaSemana = [1,2,3,4,5,6,7];

  @override
    void initState() {
      super.initState();
      final atividade = AppData.listaAtividades[widget.index];
      _titleController.text = atividade.title;
      _categoriaSelecionada = atividade.categoria;
      _horarioSelecionado = atividade.horario;
      diasSelecionados = List<int>.from(atividade.dias);
    }

  void _selecionarHorario() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _horarioSelecionado = time);
    }
  }

  void _salvarAtividade() async{
    if (_titleController.text.isEmpty || _categoriaSelecionada == null || _horarioSelecionado == null || diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }


    final novaAtividade = AtividadeModel(title: _titleController.text, categoria: _categoriaSelecionada as String, horario: _horarioSelecionado as TimeOfDay, dias: diasSelecionados, completed: false);

    AppData.listaAtividades[widget.index] = novaAtividade;

    await AppDataService.salvarTudo();
    if (!mounted) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
  }

  @override
  Widget build(BuildContext context) {

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Editar ${_titleController.text}', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Nome da Atividade',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 20),

              // Categoria
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
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
                  Text('Horário:', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    _horarioSelecionado?.format(context) ?? 'Selecione',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _selecionarHorario,
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                    child: Text('Escolher', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Dias da semana
              Text('Dias da Semana:', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
              Wrap(
                spacing: 8,
                children: diasDaSemana.map((dia) {
                  final selecionado = diasSelecionados.contains(dia);
                  return FilterChip(
                    label: Text(DiaSemana(dia), style: TextStyle(color: selecionado ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyLarge?.color),),
                    labelStyle: TextStyle(color: selecionado ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).textTheme.bodyLarge?.color,),
                    selected: selecionado,
                    checkmarkColor: Theme.of(context).scaffoldBackgroundColor,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context).primaryColor,
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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