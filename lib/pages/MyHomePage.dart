import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vital/cloud_service.dart';
import 'package:vital/themeNotifier.dart';
import '../app_data.dart';
import 'AddQuickActionPage.dart';
import '../models/DailyChallenge.dart';
import '../widgets/ChangeTile.dart';
import '../pages/menuShop.dart';
import 'package:provider/provider.dart';
import '../pages/AmigosPage.dart';
import '../widgets/stepsCounterCard.dart';
import '../pages/ActivityRoutinePage.dart';
import '../pages/TreinoRoutinePage.dart';
import '../pages/ConvitesPage.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  bool temConvitesPendentes = false;
  bool temRespostasPendentes = false;

  @override
void initState() {
  super.initState();
  if (AppData.ultimate){
    verificarConvitesPendentes();
  }
}

  Future<void> verificarConvitesPendentes() async {
    BackupService backupService = BackupService();
  final convites = await backupService.getReceivedWorkoutInvites(uid: AppData.id);
  final respostas = await backupService.getResponsesToWorkoutInvites(AppData.id);
  print(AppData.id);
  print(convites);
  setState(() {
    temConvitesPendentes = convites.any((c) => c['status'] == 'pending');
    temRespostasPendentes = respostas.isNotEmpty;
  });
  backupService.deleteOldPendingInvites();
}




  void navigateToQuickAction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddQuickActionPage()),
    );

    if (result == true) {
      setState(() {}); // força reconstrução da Home com os novos dados
    }
  }

  bool isHojeNaLista(List<int> diasDaSemana) {
  int weekday = DateTime.now().weekday;
  return diasDaSemana.contains(weekday);
}

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
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
        SingleChildScrollView(
      child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (temConvitesPendentes)
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text(
              "📨 Existem convites para você!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (temRespostasPendentes)
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text(
              "📨 Existem respostas para você!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
           Padding(
            padding: EdgeInsets.only(top: 80.0),
            child: Text('Dashboard', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 40.0, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
          ),
          Row(
            children: [
              SizedBox(width: 20,),
              _buildAvatar(),
              Spacer(),
              _buildCoinsDisplay(),
            ],
          ),
          AppData.waterConsumed < 1000 ? _buildCard(Icons.water_drop, "Água", '${AppData.waterConsumed} ml') : _buildCard(Icons.water_drop, "Água", '${AppData.waterConsumed/1000} L'),
          _buildCard(Icons.medication, "VitalTrack", "${AppData.listaAtividades.where((el) => el.categoria == 'Saúde' && el.completed).toList().length}/${AppData.listaAtividades.where((el) => el.categoria == 'Saúde' && isHojeNaLista(el.dias)).toList().length}"),
          _dailyCard(AppData.dailyChallenges),
          RotinaCard(Icons.calendar_month, "Rotina"),
          if (AppData.ultimate) StepCounterPage(),
          if (AppData.ultimate) FriendsCard(FontAwesomeIcons.peopleGroup, 'Amigos'),
          SizedBox(height: 50,),
        ],
      ),
    ),
    Positioned(
  bottom: 20,
  right: 20,
  child: SizedBox(
    width: 55, // ⬅️ Aumente esse valor pra ajustar o tamanho
    height: 55,
    child: FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const CircleBorder(), // 🔵 Garante que ele seja redondo
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(100)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildAddQuickAction(),
          ),
        );
      },
      child: Icon(Icons.add, color: Colors.black, size: 35),
    ),
  ),
),
      ],),
    );
  }

  Widget _buildCard(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color, size: 30.0),
                  const SizedBox(width: 20),
                  Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25, fontFamily: 'Montserrat')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(value, style:  TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 40, fontFamily: 'Montserrat')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget RotinaCard(IconData icon, String title){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color, size: 30.0),
                  const SizedBox(width: 20),
                  Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25, fontFamily: 'Montserrat')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(children: [
                  Spacer(),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Activityroutinepage()));
                    },
                   child: Padding(padding: EdgeInsets.all(5),
                   child: Row(children: [
                    Column(children: [
                      Icon(Icons.directions_run, color:Theme.of(context).scaffoldBackgroundColor, size: 40,),
                      SizedBox(height: 10,),
                    Text('Atividades', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 12),),
                    ],)
                   ],),),
                   ),
                  Spacer(),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Workoutroutinepage()));
                    },
                   child: Padding(padding: EdgeInsets.all(5),
                   child: Row(children: [
                    Column(children: [
                      Icon(Icons.fitness_center, color:Theme.of(context).scaffoldBackgroundColor, size: 40,),
                      SizedBox(height: 10,),
                    Text('treinos', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 12),),
                    ],)
                   ],),),
                   ), 
                   Spacer(),
                ],) 
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget FriendsCard(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color, size: 30.0),
                  const SizedBox(width: 20),
                  Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 25, fontFamily: 'Montserrat')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(children: [
                  Spacer(),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AmigoPage()));
                    },
                   child: Padding(padding: EdgeInsets.all(10),
                   child: Row(children: [
                    Column(children: [
                      Icon(FontAwesomeIcons.rankingStar, color:Theme.of(context).scaffoldBackgroundColor, size: 30,),
                      SizedBox(height: 10,),
                    Text('Veja o Ranking dos seus amigos', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
                    ],)
                   ],),),
                   ),
                  Spacer(),
                ],) 
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget _dailyCard(List<DailyChallengeModel> dailyChallenges){

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.videogame_asset, color: Theme.of(context).textTheme.bodyLarge?.color, size: 30.0),
                  const SizedBox(width: 20),
                  Text('Desafios Diários', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30, fontFamily: 'Montserrat')),
                ],
              ),
              SizedBox(height: 10,),
              Text('Nível ${AppData.level}', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontFamily: 'Montserrat')),
            LinearProgressIndicator(
                value: AppData.exp / (100 + (AppData.level - 1) * 50),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                minHeight: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                ...dailyChallenges.map((challenge) => ChallengeTile(challenge, onCoinsChanged: () {
    setState(() {}); // 🔥 força rebuild da home e atualiza moedas
  },)),
              ],
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddQuickAction() {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.4),
  width: 5,
), 
            ),
            shadowColor: const Color.fromARGB(221, 0, 0, 0),
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Text(
                "Adicionar ação rápida",
                style:  TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 25,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Positioned(
          top: -25,
          child: Material(
            elevation: 6,
            shape: const CircleBorder(),
            color: Colors.transparent,
            child: FloatingActionButton(
              onPressed: navigateToQuickAction,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.add, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(red: 0, blue: 0, green: 0), size: 30),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCoinsDisplay() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.monetization_on, color: Theme.of(context).colorScheme.secondary, size: 28),
        const SizedBox(width: 8),
        Text(
          "${AppData.coins}",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 22,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}


Widget _buildAvatar() {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 10),
    child: _AvatarPulse(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Theme.of(context).primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.mail, color: Theme.of(context).textTheme.bodyLarge?.color),
                          title: Text("Convites", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          onTap: () async {
                            var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ConvitesPage()));
                            result == null? result = false : result = true;
                            if (result) {
                              setState(() {});
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.store, color: Theme.of(context).textTheme.bodyLarge?.color),
                          title: Text("Loja", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          onTap: () async {
                            var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MenushopPage()));
                            result == null? result = false : result = true;
                            if (result) {
                              setState(() {});
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              );
            },
            child: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(AppData.avatars.firstWhere((el) => el.name == AppData.currentAvatar).imagePath),
              backgroundColor: AppData.avatars.firstWhere((el) => el.name == AppData.currentAvatar).exclusive
                  ? Colors.amber
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),

          // 🔔 Bolinha de notificação
          if (temConvitesPendentes || temRespostasPendentes || AppData.avatars.map((el) => el.requiredLevel > 1).toList().contains(AppData.level) || AppData.themes.map((el) => el.requiredLevel > 1).toList().contains(AppData.level))
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.greenAccent[400],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
}

class _AvatarPulse extends StatefulWidget {
  final Widget child;
  const _AvatarPulse({required this.child});

  @override
  State<_AvatarPulse> createState() => _AvatarPulseState();
}

class _AvatarPulseState extends State<_AvatarPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}