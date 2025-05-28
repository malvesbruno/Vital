import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vital/themeNotifier.dart';
import 'dart:ui' as ui;
import '../pages/AddActivityPage.dart';
import '../pages/EditActivityPage.dart';
import '../models/AtividadeModel.dart';
import '../app_data.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  final List<AtividadeModel> lista;
  final Function(String) onComplete;
  final double progresso;

  const ActivityPage({super.key, required this.lista, required this.progresso, required this.onComplete});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {

  @override
  void initState() {
    super.initState();
  }

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
    if (concluidas > 0 || atividadesHoje.isNotEmpty){
      AppData.progress = concluidas / atividadesHoje.length;
    } else{
      AppData.progress = 0;
    }

  }


  @override
  Widget build(BuildContext context) {
    bool vazio = widget.lista.every((item) => item.completed);
    if (!vazio){
      return Scaffold(
        extendBodyBehindAppBar: true,
      backgroundColor: AppData.isExclusiveTheme ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:  AppData.isExclusiveTheme ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Atividades', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold)),
      ),
      body: Stack(children: [
        Consumer<ThemeNotifier>(builder: (context, themeNotifier, child){
        if (!AppData.isExclusiveTheme) {
      return const SizedBox.shrink(); // Não mostra nada
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(themeNotifier.currentTheme.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7), // 👈 escurece a imagem
            BlendMode.darken,
          ),
        ),
      ),
    );
    },),
        SafeArea(
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
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
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const ui.Size(double.infinity, 50),
          ),
          child: Text("Adicionar Atividade", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ),
      ),
      const SizedBox(height: 30), // espaço após o botão
    ],
  ),
),
      ],)
    );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:  AppData.isExclusiveTheme ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor ,
        elevation: 0,
        title: Text('Atividades', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold)),
      ),
      body: 
      Stack(children: [
        Consumer<ThemeNotifier>(builder: (context, themeNotifier, child){
        if (!AppData.isExclusiveTheme) {
      return const SizedBox.shrink(); // Não mostra nada
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(themeNotifier.currentTheme.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7), // 👈 escurece a imagem
            BlendMode.darken,
          ),
        ),
      ),
    );
    },),
        SafeArea(
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
  child: 
  Padding(padding: EdgeInsets.symmetric(horizontal: 30),
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
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const ui.Size(double.infinity, 50),
          ),
    child: Text(
      "Adicionar Atividade",
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
    ),
  ),)
)

)

          ],
        ),
      ),
      ],)
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
              backgroundColor: Theme.of(context).primaryColor,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${(progress * 100).toStringAsFixed(1)}%",
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16),
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
            backgroundColor: const Color.fromARGB(255, 68, 102, 161),
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
            icon: Icons.edit,
            label: 'Editar',
            
          ),
          SlidableAction(
            onPressed: (_) async{final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title:  Text('Confirmar Exclusão', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
        content:  Text('Tem certeza que deseja excluir esta atividade?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
            icon: Icons.delete,
            label: 'Excluir',
          ),
        ],
      ),
      child: Card(
        color: Theme.of(context).primaryColor,
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
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 25,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${timeOfDayToString(atividade.horario)} - ${atividade.categoria}',
                      style:  TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                      ),
                    ),
                    Center(child: Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(children: [
                      Spacer(),
                      Icon(FontAwesomeIcons.arrowLeft, color:Theme.of(context).textTheme.bodyLarge?.color, size: 13,),
                      Text(' Deslize para mais ações', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    minimumSize: const ui.Size(50, 50),
                  ),
                  child: Icon(Icons.check, size: 30, color: Theme.of(context).textTheme.bodyLarge?.color),
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
