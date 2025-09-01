
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vital/app_data.dart';
import '../pages/LojaAvatarPage.dart';
import '../pages/LojaColorPage.dart';


// menu do shop
class MenushopPage extends StatefulWidget {
  const MenushopPage({super.key});

  @override
  State<MenushopPage> createState() => _MenushopPageState();
}

class _MenushopPageState extends State<MenushopPage> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  // leva para o avatar page
 void _navigateToavatarPage() async{
    await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AvatarStorePage(avatars: AppData.avatars, userLevel: AppData.level)),
        );
}

// leva para color page
void _navigateToColorPage() async{
    await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ColorsStorePage(colors: AppData.themes, userLevel: AppData.level)),
        );
}

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
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
          'Lojinha',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            buildCard('Avatars', 'Novo avatar, mesma preguiça!', FontAwesomeIcons.users, _navigateToavatarPage),
            buildCard('Cores', 'Pinte tudo, até o que não devia!', FontAwesomeIcons.palette, _navigateToColorPage),
            Spacer(),
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