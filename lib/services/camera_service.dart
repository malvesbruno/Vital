import 'package:permission_handler/permission_handler.dart';

//pede permisão para câmera

Future<void> solicitarPermissaoCamera() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}