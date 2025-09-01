import 'package:flutter/material.dart';


// preview de cores
class DeluxeThemePreview extends StatelessWidget {
  final List<String> deluxeTheme = [
    'assets/colors/themes/sea.png',
    'assets/colors/themes/space.png',
    'assets/colors/themes/faroeste.png',
    'assets/colors/themes/fire.png',
    'assets/colors/themes/city.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: deluxeTheme.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index < deluxeTheme.length) {
            return CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage(deluxeTheme[index], ), // substitua pelo avatar atual do usuário
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