import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vital/app_data_service.dart';
import 'package:vital/models/AmigoModel.dart';
import '../app_data.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../services/camera_service.dart';
import '../pages/qrCodeScanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cloud_service.dart';


// página mostra ranking de amigos
class AmigoPage extends StatefulWidget {
  const AmigoPage({super.key});

  @override
  State<AmigoPage> createState() => _AmigoPageState();
}

class _AmigoPageState extends State<AmigoPage>{
  late List<AmigoModel> ranking; // cria a lista de ranking
  late String id; // cria a veriável do id a ser buscado
  final TextEditingController _idController = TextEditingController(); // controle do input para adicionar amigos

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ranking = [
    ...AppData.amigos,
    AmigoModel(nome: AppData.name, avatar: AppData.currentAvatar, level: AppData.level, id: AppData.id)
  ]; // te adiciona no ranking
  ranking.sort((a, b) => b.level.compareTo(a.level)); // ordena o ranking
  }

  // leva para a página que escaneia o qrCode
  Future<String?> scanQRCode(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => QRViewExample()),
  );
  return result as String?;
}

//recarrega o ranking
void recarregarRanking() {
  setState(() {
    ranking = [
      ...AppData.amigos,
      AmigoModel(nome: AppData.name, avatar: AppData.currentAvatar, level: AppData.level, id: AppData.id),
    ];
    ranking.sort((a, b) => b.level.compareTo(a.level));
  });
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

  Future<String?> showSelectWorkoutDialog(BuildContext context) async {
  String? selectedWorkout = 'Peito'; // valor padrão
  final workouts = ['Peito', 'Costas', 'Ombro', 'Perna', 'Braços'];

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Escolha o treino para convidar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
        backgroundColor: Theme.of(context).primaryColor,
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: workouts.map((workout) {
                return RadioListTile<String>(
                  title: Text(workout, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
                  value: workout,
                  groupValue: selectedWorkout,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  fillColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                  onChanged: (value) {
                    setState(() {
                      selectedWorkout = value;
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null), // cancelar
            child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedWorkout), // confirmar
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
            ),
            child: Text('Confirmar', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
          ),
        ],
      );
    },
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
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5), fontSize:13, fontWeight: FontWeight.bold),),
                    
                    Row(children: [
                      Text(
                      nome,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if(AppData.id == id) IconButton(
    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary, size: 20,),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: nome);
          return AlertDialog(
            title: Text("Alterar nome", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),),
            backgroundColor: Theme.of(context).primaryColor,
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Novo nome"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  // Atualiza no Firebase
                  BackupService backup = BackupService();
                  backup.updateUser(AppData.id, {
                    'name': controller.text,
                  });

                  setState(() {
                    ranking.firstWhere((e) => e.id == AppData.id).nome = controller.text;
                  });

                  Navigator.pop(context);
                },
                child: Text("Salvar"),
              ),
            ],
          );
        },
      );
    },
  ),
                    ],),
                    if (AppData.id != id)
  ElevatedButton(
    onPressed: () {
      // Aqui você pode enviar notificação, marcar no banco, etc.
      showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: '',
  pageBuilder: (_, __, ___) => Center(
    child: Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppData.avatars.firstWhere((el) => el.name == avatar).exclusive
                ? Colors.amber
                : Theme.of(context).textTheme.bodyLarge?.color,
              backgroundImage: AssetImage(AppData.avatars.firstWhere((e) => e.name == avatar).imagePath),
            ),
            SizedBox(height: 10),
            Text(nome, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Nível $level", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(
              "Você deseja convidar $nome para treinar hoje?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: ()  async {
                  final treinoEscolhido = await showSelectWorkoutDialog(context);
                  if (treinoEscolhido == null) return; // Se o usuário cancelar
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Convite enviado para $nome! Treino: $treinoEscolhido")),
                  );

                  BackupService backupService = BackupService();
                  backupService.sendWorkoutInvite(
                    senderId: AppData.id,
                    receiverId: id,
                    workoutSuggestion: treinoEscolhido.toLowerCase(), // formata para minúsculas se quiser
                  );
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(
                    "Enviar convite",
                    style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  ),
);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text("Convidar", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
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
                      onPressed: () async {
                        BackupService backupService = BackupService();
  final data = await backupService.getUser(_idController.text);

  if (data == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Usuário não encontrado.")),
    );
    return;
  }

  final amigoId = _idController.text;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppData.avatars.firstWhere((el) => el.name == data["current_avatar"]).exclusive ? Colors.amber : Theme.of(context).textTheme.bodyLarge?.color,
                backgroundImage: AssetImage(
                  AppData.avatars.firstWhere((e) => e.name == data["current_avatar"]).imagePath,
                ),
              ),
              SizedBox(height: 10),
              Text(data["name"], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Nível ${data["level"]}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  AppData.amigos.add(
                   AmigoModel(nome: data['name'], avatar: data['current_avatar'] ?? 'Deafult', level: data['level'], id: amigoId)
                  );
                  final amigosJson = AppData.amigos.map((t) => t.toJson()).toList();

                  AppDataService.salvarTudo();

                  backupService.updateUser(AppData.id, {
                    'amigos': jsonEncode(amigosJson),
                  });


                  List<dynamic> parseList(dynamic data) {
                    if (data is String) return jsonDecode(data);
                    return data ?? [];
                  }

                  var friends_of_amigos = parseList(data['amigos'])
          .map((a) => AmigoModel.fromJson(a))
          .toList();

                  friends_of_amigos.add(
                    AmigoModel(nome: AppData.name, avatar: AppData.currentAvatar, level: AppData.level, id: AppData.id)
                  );
                  final friends_of_amigosJson = friends_of_amigos.map((t) => t.toJson()).toList();

                  backupService.updateUser(id, {
                    'amigos': jsonEncode(friends_of_amigosJson),
                  });

                  recarregarRanking();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${data["name"]} adicionado com sucesso!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text("Adicionar", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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