import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// Tela para ler QrCode

class QRViewExample extends StatefulWidget {
  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController ctrl) {
          controller = ctrl;
          ctrl.scannedDataStream.listen((scanData) {
            controller?.pauseCamera();
            Navigator.pop(context, scanData.code);
          });
        },
      ),
    );
  }
}
