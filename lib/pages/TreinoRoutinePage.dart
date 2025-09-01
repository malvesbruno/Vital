import 'package:flutter/material.dart';
import 'package:vital/models/TreinoModel.dart';
import '../app_data.dart';
import '../pages/EditActivityPage.dart';
import '../app_data_service.dart';
import '../cloud_service.dart';
import 'dart:convert';

// rotina de treino
class Workoutroutinepage extends StatefulWidget{
  const Workoutroutinepage({super.key});

  @override
  State<Workoutroutinepage> createState() => _WorkoutRoutinePageState();
}

class _WorkoutRoutinePageState extends State<Workoutroutinepage>{
  final ScrollController _tabScrollController = ScrollController(); // controle de scroll


    @override
  void initState() {
    super.initState();
    // Espera o layout ser montado antes de rolar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabScrollController.jumpTo(55); // ajuste esse valor como quiser
    });
  }


  @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 7,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Rotina de treinos",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
  preferredSize: const Size.fromHeight(kToolbarHeight),
  child: SingleChildScrollView(
    controller: _tabScrollController,
    scrollDirection: Axis.horizontal,
    child: TabBar(
      isScrollable: true,
      labelColor: Theme.of(context).colorScheme.secondary,
      unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
      indicatorColor: Theme.of(context).colorScheme.secondary,
      tabs: const [
        Tab(text: 'Seg'),
        Tab(text: 'Ter'),
        Tab(text: 'Qua'),
        Tab(text: 'Qui'),
        Tab(text: 'Sex'),
        Tab(text: 'Sáb'),
        Tab(text: 'Dom'),
      ],
    ),
  ),
),

      ),
      body: TabBarView(
        children: List.generate(7, (index) {
          return _buildDayActivities(context, index + 1); // 1 = Segunda
        }),
      ),
    ),
  );
  }

  Widget _buildDayActivities(BuildContext context, int weekday) {
  // Simulação de atividades — depois você usa seus dados reais
  final activities = AppData.treinos.where((a) => a.diasSemana.contains(weekday)).toList();

  if (activities.isEmpty) {
    return Center(child: Text("Nenhuma atividade para este dia."));
  }

  return ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: activities.length,
    itemBuilder: (context, index) {
      final treino = activities[index];
      return Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Text(treino.nome, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),),
          subtitle: Text(treino.horario.format(context), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          onTap: () => _showActivityOptions(context, treino, AppData.treinos.indexOf(treino)),
        ),
      );
    },
  );
  
}


  void _showActivityOptions(BuildContext context, TreinoModel treino, int index) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: 
      Container(
        color: Theme.of(context).primaryColor,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: Theme.of(context).textTheme.bodyLarge?.color,),
            title: Text("Editar", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditActivityPage(index: index,
                  ),
                ),
              );
              // Implemente a edição
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Theme.of(context).textTheme.bodyLarge?.color),
            title: Text("Excluir", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            onTap: () async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Confirmar Exclusão', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text('Tem certeza que deseja excluir esta atividade?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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
      // Exclui a atividade da lista (ou AppData, conforme sua lógica)
      setState(() async{
        AppData.treinos.remove(treino);
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
        // ou se for uma lista passada via widget: widget.lista.remove(activity);
      });
      Navigator.pop(context); // fecha o bottom sheet depois da exclusão
    }
  },
          ),
        ],
      ),
      )
    ),
  );
}
}
