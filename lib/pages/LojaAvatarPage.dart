import 'package:flutter/material.dart';
import 'package:vital/app_data.dart';
import '../models/AvatarModel.dart';
import '../widgets/zeldaBackground.dart';
import 'package:audioplayers/audioplayers.dart';


class AvatarStorePage extends StatefulWidget {
  final List<AvatarModel> avatars;
  final int userLevel;

  const AvatarStorePage({
    super.key,
    required this.avatars,
    required this.userLevel,
  });

  @override
  _AvatarStorePageState createState() => _AvatarStorePageState();
}

class _AvatarStorePageState extends State<AvatarStorePage> {
  int coins = AppData.coins;

  void _showZeldaUnlockAnimation(BuildContext context, AvatarModel avatar) async{
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
                    backgroundImage: AssetImage(avatar.imagePath),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Novo avatar desbloqueado!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
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


  void _showAvatarDialog(BuildContext context, AvatarModel avatar) {
  setState(() {}); // força rebuild antes do diálogo, só pra garantir
  final updatedAvatar = widget.avatars.firstWhere((a) => a.name == avatar.name);
  final isUnlocked = widget.userLevel >= updatedAvatar.requiredLevel;
  final hasCoins = AppData.coins >= updatedAvatar.price;
  final alreadyOwned = updatedAvatar.owned;
  final isSelected = AppData.currentAvatar == updatedAvatar.name;

  String buttonText = '';
  bool isButtonEnabled = false;
  Color buttonColor = Colors.grey;

  if (!isUnlocked) {
    buttonText = 'Nível ${updatedAvatar.requiredLevel} necessário';
    isButtonEnabled = false;
    buttonColor = Colors.grey.shade700;
  } else if (!alreadyOwned && !hasCoins) {
    buttonText = '${updatedAvatar.price}\nmoedas (insuficiente)';
    isButtonEnabled = false;
    buttonColor = Colors.red.shade300;
  } else if (!alreadyOwned && hasCoins) {
    buttonText = 'Comprar avatar\n(${updatedAvatar.price} moedas)';
    isButtonEnabled = true;
    buttonColor = Colors.green;
  } else if (alreadyOwned && !isSelected) {
    buttonText = 'Usar avatar';
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
          updatedAvatar.name ,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage(updatedAvatar.imagePath), // substitua pelo avatar atual do usuário
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
                    Navigator.pop(context, true);
                    if (!alreadyOwned) {
                      AppData.buyAvatar(updatedAvatar.name); // sua lógica aqui
                      setState(() {
                          coins = AppData.coins; // <- aqui atualiza a interface com o novo valor
                        });
                      // você pode disparar uma animação ou som aqui;
                      _showZeldaUnlockAnimation(context, updatedAvatar);
                      AppData.salvarDados(); // força rebuild pra atualizar moedas
                    } else if (!isSelected) {
                      AppData.currentAvatar = updatedAvatar.name;
                      setState(() {});
                      AppData.salvarDados();
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
            const Text('Avatares'),
            const Spacer(),
            _buildCoinsDisplay(),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
          const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
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
            color: Colors.white, // fundo branco
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
