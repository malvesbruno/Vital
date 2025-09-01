import 'package:flutter/material.dart';

// preview de avatar

class DeluxeAvatarsPreview extends StatelessWidget {
  final List<String> deluxeAvatars = [
    'assets/avatares/mr_vega.png',
    'assets/avatares/vinil_veneno.png',
    'assets/avatares/tacitus.png',
    'assets/avatares/sad_saddler.png',
    'assets/avatares/red_rebellion.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deluxeAvatars.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index < deluxeAvatars.length) {
            return CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage(deluxeAvatars[index], ), // substitua pelo avatar atual do usuário
        backgroundColor: Colors.amber,
      );
          } else {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.white, size: 32),
              ],
            );
          }
        },
      ),
    );
  }
}