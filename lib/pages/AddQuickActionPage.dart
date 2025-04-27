
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../pages/addWaterIntake.dart';
import '../pages/AddRemedyIntake.dart';
import 'SetTreinoRapidoPage.dart';
import '../pages/AddSleepIntake.dart';

class AddQuickActionPage extends StatefulWidget {
  const AddQuickActionPage({super.key});

  @override
  State<AddQuickActionPage> createState() => _AddQuickActionPageState();
}

class _AddQuickActionPageState extends State<AddQuickActionPage> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  void _navigateToWaterIntake() async{
          final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWaterIntakePage()),
              );

              if (result == true) {
                Navigator.pop(context, true); // retorna também pro nível acima
        }
}

  void _navigateToRemedyIntake() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddRemdyIntakePage()),
  );

  // Se já deu pop lá dentro, não precisa repetir aqui
  if (result == true) {
    // Aqui só age com base no retorno, não fecha de novo
    // Só faz algo se quiser, tipo mostrar um SnackBar ou atualizar estado
  }
}

void _navigateToSetTreino() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SetTreinoRapidoPage()),
  );

  // Se já deu pop lá dentro, não precisa repetir aqui
  if (result == true) {
    // Aqui só age com base no retorno, não fecha de novo
    // Só faz algo se quiser, tipo mostrar um SnackBar ou atualizar estado
  }
}

  void _navigateToSleepLog() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddSleepIntakePage()),
  );

  // Se já deu pop lá dentro, não precisa repetir aqui
  if (result == true) {
    // Aqui só age com base no retorno, não fecha de novo
    // Só faz algo se quiser, tipo mostrar um SnackBar ou atualizar estado
  }
}


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          'Adicionar Ação Rápida',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 120),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: child,
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: IconButton(
                    icon: Icon(Icons.water_drop, color: Theme.of(context).textTheme.bodyLarge?.color, size: 80),
                    onPressed: _navigateToWaterIntake
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Beber Água',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            buildCard('VitalTrack', 'Marque um remédio/suplemento ingerido', Icons.medication, _navigateToRemedyIntake),
            buildCard('Treino em Casa', 'Registre um treino curto ou improvisado', FontAwesomeIcons.personRunning, _navigateToSetTreino),
            buildCard('Descanso', 'Adicione um momento de relaxamento ou sono', Icons.bedtime, _navigateToSleepLog),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String text, String subText, IconData icone, Function toDo) {
  return Padding(
    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
    child: InkWell(
      onTap: () {
        toDo();
      }, // Ação ao tocar no card
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Row(
            children: [
              Icon(icone, size: 30, color: Theme.of(context).textTheme.bodyLarge?.color),
              SizedBox(width: 20),
              // A coluna com o texto foi envolvida pelo Expanded
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Adiciona "..." quando o texto ultrapassa
                      softWrap: true, // Permite quebra de linha quando necessário
                    ),
                    Text(
                      subText,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Adiciona "..." quando o texto ultrapassa
                      softWrap: true, // Permite quebra de linha quando necessário
                    ),
                  ],
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