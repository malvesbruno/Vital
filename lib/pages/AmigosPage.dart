import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vital/models/AmigoModel.dart';
import '../app_data.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../services/camera_service.dart';
import '../pages/qrCodeScanner.dart';
import 'package:permission_handler/permission_handler.dart';

class AmigoPage extends StatefulWidget {
  const AmigoPage({super.key});

  @override
  State<AmigoPage> createState() => _AmigoPageState();
}

class _AmigoPageState extends State<AmigoPage>{
  late List<AmigoModel> ranking;
  late String id;
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ranking = [
    ...AppData.amigos,
    AmigoModel(nome: AppData.name, avatar: AppData.currentAvatar, level: AppData.level, id: AppData.id)
  ];
  ranking.sort((a, b) => b.level.compareTo(a.level));
  }

  Future<String?> scanQRCode(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => QRViewExample()),
  );
  return result as String?;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Amigos",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: 
      Stack(children: [
         SingleChildScrollView(
        child: Center(
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                Text("Ranking", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize:35, fontWeight: FontWeight.bold, fontFamily: 'Montserrat', fontStyle: FontStyle.italic),),
                Spacer(),
                Icon(FontAwesomeIcons.rankingStar, color:Theme.of(context).colorScheme.secondary, size: 30,),
                Spacer(),
              ],
            ),
            
            ...ranking.map((s) => buildCard(s.nome, s.level, s.avatar, s.id)),
            SizedBox(height: 30,),
            Text("Seu ID:", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize:20, fontWeight: FontWeight.bold),),
            SizedBox(height: 5,),
            QrImageView(data: AppData.id, size: 200, backgroundColor: const Color.fromARGB(255, 255, 255, 255),),
            SizedBox(height: 10,),
            SizedBox(width: 200,
            child:  ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: AppData.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ID copiado para a área de transferência')),
                );
              }, child: Row(
                children: [
                  Spacer(),
                  Text('Copiar ID', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize:20, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  Spacer(),
                  Icon(Icons.copy, size: 20, color: Theme.of(context).scaffoldBackgroundColor,),
                  Spacer()
                ],
              )),)
           ,
            SizedBox(height: 250),
          ],
        ),
      ),
      ),
      Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: buildAddFriend()),
      ],)
    );
  }

  Widget buildCard(String nome, int level, String avatar, String id){
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, top: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: Card(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Row(
              children: [
                CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(AppData.avatars.firstWhere((el) => el.name == avatar).imagePath), // substitua pelo avatar atual do usuário
                backgroundColor: AppData.avatars.firstWhere((el) => el.name == avatar).exclusive ? Colors.amber : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(AppData.id == id) Text(
                      "Você",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5), fontSize:13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      nome,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Lvl",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5,),
                    Icon(FontAwesomeIcons.trophy, color: Theme.of(context).colorScheme.secondary, size: 20,),
                    Text(
                      "$level",
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddFriend() {
  return Padding(
    padding: EdgeInsets.all(5),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(100),
              width: 5,
            ),
          ),
          shadowColor: const Color.fromARGB(221, 0, 0, 0),
          elevation: 20,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Column(
                  children: [
                    TextField(
                    controller: _idController,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      labelText: 'ID do seu Amigo',
                      labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        id = value;
                      });
                    },
                  ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Buscar Amigo',
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        // Botão redondo com ícone de câmera
        Positioned(
          top: -30,
          left: 0,
          right: 0,
          child: Center(child:
          SizedBox(
  width: 60,
  height: 60,
  child: GestureDetector(
        onTap: () async{
          await solicitarPermissaoCamera();
          var status = await Permission.camera.status;
          if (status.isGranted){
            final code = await scanQRCode(context);
            if (code != null) {
              print('Código escaneado: $code');
              setState(() {
                id = code;
                _idController.text = code;
              });
            }
          }
        },
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary, // Cor de fundo
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor, // Cor da borda
              width: 3,            // Espessura da borda
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Icon(Icons.camera_alt, size: 35, color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),

),)
        ),
      ],
    ),
  );
}}