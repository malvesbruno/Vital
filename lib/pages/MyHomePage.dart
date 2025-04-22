import 'package:flutter/material.dart';
import '../app_data.dart';
import 'AddQuickActionPage.dart';
import '../models/DailyChallenge.dart';
import '../widgets/ChangeTile.dart';
import '../pages/menuShop.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {


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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 80.0),
            child: Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 40.0, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
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
          SizedBox(height: 20,),
          _buildAddQuickAction()
        ],
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: const Color.fromARGB(255, 31, 31, 31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: Colors.grey, size: 30.0),
                  const SizedBox(width: 20),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Montserrat')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 40, fontFamily: 'Montserrat')),
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
        color: const Color.fromARGB(255, 31, 31, 31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.videogame_asset, color: Colors.grey, size: 30.0),
                  const SizedBox(width: 20),
                  Text('Desafios Diários', style: const TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Montserrat')),
                ],
              ),
              SizedBox(height: 10,),
              Text('Nível ${AppData.level}', style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Montserrat')),
            LinearProgressIndicator(
                value: AppData.exp / (100 + (AppData.level - 1) * 50),
                backgroundColor: const Color.fromARGB(63, 255, 255, 255),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
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
            color: const Color.fromARGB(255, 31, 31, 31),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide.none, // 🔥 Remove qualquer borda
            ),
            shadowColor: const Color.fromARGB(0, 205, 223, 0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Text(
                "Adicionar ação rápida",
                style: const TextStyle(
                  color: Colors.white,
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
              backgroundColor: Colors.teal.shade700,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
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
        Icon(Icons.monetization_on, color: Colors.amber, size: 28),
        const SizedBox(width: 8),
        Text(
          "${AppData.coins}",
          style: const TextStyle(
            color: Colors.white,
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
      child: GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color.fromARGB(255, 40, 40, 40),
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
                    leading: Icon(Icons.store, color: Colors.white),
                    title: Text("Loja", style: TextStyle(color: Colors.white)),
                    onTap: () async{
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MenushopPage()));
                      // Navegar para tela da loja
                      if(result){
                        setState(() {
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(height: 40,)
                ],
              ),
            );
          },
        );
      },
      child: CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage(AppData.avatars.firstWhere((el) => el.name == AppData.currentAvatar).imagePath), // substitua pelo avatar atual do usuário
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    ),
    )
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