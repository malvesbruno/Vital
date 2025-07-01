import 'package:flutter/material.dart';
import 'package:vital/app_data.dart';
import '../models/ColorsModel.dart';
import '../widgets/zeldaBackground.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:vital/themeNotifier.dart';
import '../pages/DeluxePage.dart';
import '../app_data_service.dart';
import '../cloud_service.dart';
import 'dart:convert';



class ColorsStorePage extends StatefulWidget {
  final List<AppTheme> colors;
  final int userLevel;

  const ColorsStorePage({
    super.key,
    required this.colors,
    required this.userLevel,
  });

  @override
  _ColorsStorePageState createState() => _ColorsStorePageState();
}

class _ColorsStorePageState extends State<ColorsStorePage> {
  int coins = AppData.coins;

  void _showZeldaUnlockAnimation(BuildContext context, AppTheme color) async{
    final player = AudioPlayer();
    await player.setVolume(1.0);
    player.play(AssetSource('sounds/buyItem.mp3'));

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar animação',
    barrierColor: Colors.black.withOpacity(0.9),
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, _, __) {
      return Center(
  child: Material(
    color: Colors.transparent,
    child: Stack(
      alignment: Alignment.center,
      children: [
        const ZeldaBackground(), // 👈 adiciona o fundo animado
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage(color.imagePath),
                    backgroundColor: const Color.fromARGB(108, 255, 255, 255),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nova Cor desbloqueada!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Continuar', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ],
    ),
  ),
);

    },
  );
}


  void _showColorDialog(BuildContext context, AppTheme color) {
  setState(() {}); // força rebuild antes do diálogo, só pra garantir
  final updateColor = widget.colors.firstWhere((a) => a.name == color.name);
  final isUnlocked = widget.userLevel >= updateColor.requiredLevel;
  final hasCoins = AppData.coins >= updateColor.price;
  final alreadyOwned = updateColor.owned;
  final isExclusive = updateColor.exclusive;
  final isSelected = AppData.currentTheme == updateColor.name;

  String buttonText = '';
  bool isButtonEnabled = false;
  Color buttonColor = Colors.grey;

  if (!isUnlocked) {
    buttonText = 'Nível ${updateColor.requiredLevel} necessário';
    isButtonEnabled = false;
    buttonColor = Colors.grey.shade700;
  } 
   else if(!alreadyOwned && !AppData.ultimate && color.exclusive){
    buttonText = 'Tema Exclusivo';
    isButtonEnabled = true;
    buttonColor = Colors.amber;
  }
  else if (!alreadyOwned && !hasCoins) {
    buttonText = '${updateColor.price}\nmoedas (insuficiente)';
    isButtonEnabled = false;
    buttonColor = Colors.red.shade300;
  } else if (!alreadyOwned && hasCoins) {
    buttonText = 'Comprar Cor\n(${updateColor.price} moedas)';
    isButtonEnabled = true;
    buttonColor = Colors.green;
  } else if (alreadyOwned && !isSelected) {
    buttonText = 'Usar Cor';
    isButtonEnabled = true;
    buttonColor = Colors.blue;
  } else if (isSelected) {
    buttonText = 'Já está usando';
    isButtonEnabled = false;
    buttonColor = Colors.grey.shade500;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Center(
        child: Text(
          updateColor.name ,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 22),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage(updateColor.imagePath), // substitua pelo avatar atual do usuário
        backgroundColor: const Color.fromARGB(108, 255, 255, 255),
      ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () async{
                  if(!alreadyOwned && !AppData.ultimate && color.exclusive){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Deluxepage()));
                  }
                  else{
                    Navigator.pop(context, true);
                    if (!alreadyOwned) {
                      AppData.buyColor(updateColor.name); // sua lógica aqui
                      setState(() {
                          coins = AppData.coins; // <- aqui atualiza a interface com o novo valor
                        });
                      // você pode disparar uma animação ou som aqui;
                      _showZeldaUnlockAnimation(context, updateColor);
                      if (AppData.ultimate){
                        final themesOwnedJson = AppData.themes.where((t) => t.owned).map((el) => el.toJson()).toList();
                        final statsJson = AppData.historicoStats.map((t) => t.toJson()).toList();
                        BackupService cloud = BackupService();
                        await cloud.updateUser(AppData.id, {
                          'temas_comprados': jsonEncode(themesOwnedJson),
                          'stats': jsonEncode(statsJson),
                          'current_avatar': AppData.currentAvatar,
                          'current_theme': AppData.currentTheme,
                          'nivel': AppData.level,
                          'coins': AppData.coins,
                        });
                      }
                      await AppDataService.salvarTudo(); // força rebuild pra atualizar moedas
                    } else if (!isSelected) {
                      Provider.of<ThemeNotifier>(context, listen: false).currentTheme = updateColor;
                      setState(() {
                        AppData.currentTheme = updateColor.name;
                      if (isExclusive){
                        AppData.isExclusiveTheme = true;
                      } else{
                        AppData.isExclusiveTheme = false;
                      }
                      });
                      await AppDataService.salvarTudo();
                    }
                  }
                  }
                : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(buttonColor),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              textStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            child: Text(buttonText, style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    ),
  );
}


  @override
  void initState() {
    super.initState();
    coins = AppData.coins; // inicializa com as moedas atuais
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Cores'),
            const Spacer(),
            _buildCoinsDisplay(),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.colors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return ColorGridItem(
            color: widget.colors[index],
            userLevel: widget.userLevel,
            onTap: () => _showColorDialog(context, widget.colors[index]),
          );
        },
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
            "$coins",
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

}



class ColorGridItem extends StatelessWidget {
  final AppTheme color;
  final int userLevel;
  final VoidCallback onTap;

  const ColorGridItem({
    super.key,
    required this.color,
    required this.userLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = userLevel >= color.requiredLevel;
    final canBuy = isUnlocked && !color.owned;

    return GestureDetector(
      onTap: () { onTap();
      },
      child: Stack(
        children: [
          Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(108, 255, 255, 255), // fundo branco
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox.expand( // <- AQUI! força ocupar 100% da área
              child: FittedBox(
                fit: BoxFit.cover, // <- Força preencher o quadrado
                clipBehavior: Clip.hardEdge,
                child: Image.asset(color.imagePath),
              ),
            ),
          )
        ),

          // Overlay de bloqueado (nível insuficiente)
          if (!isUnlocked)
            _overlay(
              icon: Icons.lock,
              label: 'Nível ${color.requiredLevel}',
              color: Colors.black.withOpacity(0.6),
            ),
        
          // Overlay de compra (nível ok, mas ainda não comprado)
          if (canBuy)
            _overlay(
              icon: Icons.monetization_on,
              label: '${color.price} moedas',
              color: Colors.orange.withOpacity(0.5),
            ),
            if (AppData.currentTheme == color.name)
            Positioned(
              right: 30,
              left: 30,
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 193, 7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: const Text(
                  'Usando',
                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
                ),
                )
                
              ),
            ),
        ],
      ),
    );
  }

  Widget _overlay({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
