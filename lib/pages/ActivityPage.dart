import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui' as ui;
import '../pages/AddActivityPage.dart';
import '../pages/EditActivityPage.dart';
import '../models/AtividadeModel.dart';
import '../app_data.dart';

class ActivityPage extends StatefulWidget {
  final List<AtividadeModel> lista;
  final Function(String) onComplete;
  final double progresso;

  const ActivityPage({super.key, required this.lista, required this.progresso, required this.onComplete});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {

  String timeOfDayToString(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
    bool vazio = widget.lista.every((item) => item.completed);
    if (!vazio){
      return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Atividades', style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
  child: ListView(
    padding: const EdgeInsets.symmetric(vertical: 10),
    children: [
      _buildActivityProgressBar(widget.progresso),
      ...widget.lista
        .where((item) => !item.completed && isHojeNaLista(item.dias))
        .map((item) => _buildCardAtividades(item, widget.onComplete))
        .toList(),
      const SizedBox(height: 20), // espaço antes do botão
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddActivityPage(
                  onAdd: (novaAtividade) {
                    setState(() {
                      widget.lista.add(novaAtividade);
                    });
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text("Adicionar Atividade", style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ),
      const SizedBox(height: 30), // espaço após o botão
    ],
  ),
),
    );
    }
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Atividades', style: TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildActivityProgressBar(widget.progresso),
            Expanded(
              child: ListView(
  children: widget.lista
      .where((item) => 
  !item.completed &&
  isHojeNaLista(item.dias)
) // 🔥 Filtra atividades não concluídas
      .map((item) => _buildCardAtividades(item, widget.onComplete))
      .toList(),
),
            ),
            Padding(
  padding: EdgeInsets.only(bottom: 20), // Move para cima
  child: Material(
  elevation: 10, // Define um z-index maior
  shadowColor: const Color.fromARGB(0, 255, 193, 7),
  borderRadius: BorderRadius.circular(20),
  color: Colors.transparent, // Mantém a transparência
  child: ElevatedButton(
    onPressed: () async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityPage(
          onAdd: (novaAtividade) {
            setState(() {
              widget.lista.add(novaAtividade);
            });
          },
        ),
      ),
    );
  },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    ),
    child: Text(
      "Adicionar Atividade",
      style: TextStyle(color: Colors.white, fontSize: 20),
    ),
  ),
)

)

          ],
        ),
      ),
    );
  }

  Widget _buildActivityProgressBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${(progress * 100).toStringAsFixed(1)}%",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAtividades(AtividadeModel atividade, Function(String) onComplete) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Slidable(
      key: ValueKey(atividade.title),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditActivityPage(index: widget.lista.indexOf(atividade),
                  ),
                ),
              );
            },
            backgroundColor: const Color.fromARGB(255, 72, 108, 137),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
            
          ),
          SlidableAction(
            onPressed: (_) async{final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 31, 31, 31),
        title: const Text('Confirmar Exclusão', style: TextStyle(color: Colors.white),),
        content: const Text('Tem certeza que deseja excluir esta atividade?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        widget.lista.remove(atividade);
        _updateProgressBar();
      });
    }
            },
            backgroundColor: const Color.fromARGB(255, 171, 54, 46),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Excluir',
          ),
        ],
      ),
      child: Card(
        color: const Color.fromARGB(255, 31, 31, 31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      atividade.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${timeOfDayToString(atividade.horario)} - ${atividade.categoria}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Center(child: Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(children: [
                      Spacer(),
                      Icon(FontAwesomeIcons.arrowLeft, color:const Color.fromARGB(105, 158, 158, 158), size: 13,),
                      Text(' Deslize para mais ações', style: TextStyle(color: const Color.fromARGB(105, 158, 158, 158),
                        fontSize: 13)),
                        Spacer(),
                    ],),)
                     
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => {
                    AppData.atualizarDailyStats(atividadeConcluida: true),
                    onComplete(atividade.title)},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    minimumSize: const ui.Size(50, 50),
                  ),
                  child: const Icon(Icons.check, size: 30, color: Colors.white),
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
