import 'package:flutter/material.dart';
import 'package:vital/app_data.dart';
import '../models/AvatarModel.dart';
import '../widgets/zeldaBackground.dart';
import 'package:audioplayers/audioplayers.dart';
import '../pages/DeluxePage.dart';
import '../app_data_service.dart';
import '../cloud_service.dart';
import 'dart:convert';
import '../services/intersticial_service_add.dart';


// Loja de avatar
class AvatarStorePage extends StatefulWidget {
  final List<AvatarModel> avatars; // lista de avatares
  final int userLevel; // nível do player

  const AvatarStorePage({
    super.key,
    required this.avatars,
    required this.userLevel,
  });

  @override
  _AvatarStorePageState createState() => _AvatarStorePageState();
}

class _AvatarStorePageState extends State<AvatarStorePage> {
  int coins = AppData.coins; //moedas do user

  // mostra uma animação quando se compra um avatar
  void _showZeldaUnlockAnimation(BuildContext context, AvatarModel avatar) async{
    final player = AudioPlayer(); // váriavel que toca áudio
    await player.setVolume(1.0); // define o volume
    player.play(AssetSource('sounds/buyItem.mp3')); // seleciona o áudio

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
                    backgroundImage: AssetImage(avatar.imagePath),
                    backgroundColor: avatar.exclusive ? Colors.amber  : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Novo avatar desbloqueado!',
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
                if (!AppData.ultimate){
                InterstitialAdService.showAd(onAdClosed: () {
      // Executar ação após o anúncio, se quiser
                  Navigator.pop(context);
                });
                } else{
                  Navigator.pop(context);
                }
                
              },
              child: Text('Continuar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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


  // mostrar o dialog 
  void _showAvatarDialog(BuildContext context, AvatarModel avatar) {
  setState(() {}); // força rebuild antes do diálogo, só pra garantir
  final updatedAvatar = widget.avatars.firstWhere((a) => a.name == avatar.name); // update os dados do avatar
  final isUnlocked = widget.userLevel >= updatedAvatar.requiredLevel; // verifica se o avatar está desbloquado
  final hasCoins = AppData.coins >= updatedAvatar.price; // tem moedas suficientes para comprar o avatar
  final alreadyOwned = updatedAvatar.owned; // já comprou
  final isSelected = AppData.currentAvatar == updatedAvatar.name; // foi selecionados

  String buttonText = ''; // texto do botão
  bool isButtonEnabled = false; // botão pode ser clicado?
  Color buttonColor = Colors.grey; // cor do botão

  // se não foi desbloqueado, não pode comprar
  if (!isUnlocked) {
    buttonText = 'Nível ${updatedAvatar.requiredLevel} necessário';
    isButtonEnabled = false;
    buttonColor = Colors.grey.shade700;
  } 
  // se não comprou, o avatar não for ultimate 
  else if(!alreadyOwned && !AppData.ultimate && avatar.exclusive){
    buttonText = 'Comprar avatar\n(${updatedAvatar.price} moedas)';
    isButtonEnabled = true;
    buttonColor = Colors.amber;
  }
  // se ainda não comprou e não tem moedas suficientes
  else if (!alreadyOwned && !hasCoins) {
    buttonText = '${updatedAvatar.price}\nmoedas (insuficiente)';
    isButtonEnabled = false;
    buttonColor = Colors.red.shade300;
    // se ainda não comprou e tem moedas, pode comprar
  } else if (!alreadyOwned && hasCoins) {
    buttonText = 'Comprar avatar\n(${updatedAvatar.price} moedas)';
    isButtonEnabled = true;
    buttonColor = Colors.green;
    // se já comprou, mas não foi selecionado
  } else if (alreadyOwned && !isSelected) {
    buttonText = 'Usar avatar';
    isButtonEnabled = true;
    buttonColor = Colors.blue;
    // se já selecionou
  } else if (isSelected) {
    buttonText = 'Já está usando';
    isButtonEnabled = false;
    buttonColor = Colors.grey.shade500;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Center(
        child: Text(
          updatedAvatar.name ,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 22),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage(updatedAvatar.imagePath), // substitua pelo avatar atual do usuário
        backgroundColor: avatar.exclusive ? Colors.amber  : Theme.of(context).textTheme.bodyLarge?.color,
      ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () async{
                  if (!alreadyOwned && !AppData.ultimate && avatar.exclusive){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Deluxepage()));
                  }
                  else{
                    Navigator.pop(context, true);
                    if (!alreadyOwned) {
                      AppData.buyAvatar(updatedAvatar.name); // sua lógica aqui
                      setState(() {
                          coins = AppData.coins; // <- aqui atualiza a interface com o novo valor
                        });
                      // você pode disparar uma animação ou som aqui;
                      _showZeldaUnlockAnimation(context, updatedAvatar);
                      if (AppData.ultimate){
                        final avatarsOwnedJson = AppData.themes.where((t) => t.owned).map((el) => el.toJson()).toList();
                        final statsJson = AppData.historicoStats.map((t) => t.toJson()).toList();
                        BackupService cloud = BackupService();
                        await cloud.updateUser(AppData.id, {
                          'avatares_comprados': jsonEncode(avatarsOwnedJson),
                          'stats': jsonEncode(statsJson),
                          'current_avatar': AppData.currentAvatar,
                          'current_theme': AppData.currentTheme,
                          'nivel': AppData.level,
                          'coins': AppData.coins,
                        });
                      }
                      await AppDataService.salvarTudo(); // força rebuild pra atualizar moedas
                    } else if (!isSelected) {
                      AppData.currentAvatar = updatedAvatar.name;
                      setState(() {});
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

            child: Text(buttonText, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
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
            const Text('Avatares'),
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
        itemCount: widget.avatars.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return AvatarGridItem(
            avatar: widget.avatars[index],
            userLevel: widget.userLevel,
            onTap: () => _showAvatarDialog(context, widget.avatars[index]),
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
            style:  TextStyle(
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

}



class AvatarGridItem extends StatelessWidget {
  final AvatarModel avatar;
  final int userLevel;
  final VoidCallback onTap;

  const AvatarGridItem({
    super.key,
    required this.avatar,
    required this.userLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = userLevel >= avatar.requiredLevel;
    final canBuy = isUnlocked && !avatar.owned;

    return GestureDetector(
      onTap: () { onTap();
      },
      child: Stack(
        children: [
          Container(
          decoration: BoxDecoration(
            color: avatar.exclusive ? Colors.amber  : Theme.of(context).textTheme.bodyLarge?.color, // fundo branco
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              avatar.imagePath,
              fit: BoxFit.contain, // ou cover, dependendo do efeito que quiser
            ),
          ),
        ),

          // Overlay de bloqueado (nível insuficiente)
          if (!isUnlocked)
            _overlay(
              icon: Icons.lock,
              label: 'Nível ${avatar.requiredLevel}',
              color: Colors.black.withOpacity(0.6),
            ),

          // Overlay de compra (nível ok, mas ainda não comprado)
          if (canBuy)
            _overlay(
              icon: Icons.monetization_on,
              label: '${avatar.price} moedas',
              color: Colors.orange.withOpacity(0.5),
            ),
            if (AppData.currentAvatar == avatar.name)
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
