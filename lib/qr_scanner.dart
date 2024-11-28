import 'dart:async'; // Importa el paquete para usar Timer
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  final String esp32Url = 'http://192.168.175.118'; // IP del ESP32
  final String validCodeFragment = "codigoEntrada";

  bool isScanning = true; // Bandera para controlar el escaneo
  Timer? _scanCooldownTimer; // Temporizador para 10 segundos

  @override
  void dispose() {
    controller?.dispose();
    _scanCooldownTimer?.cancel(); // Cancela el temporizador al cerrar la vista
    super.dispose();
  }

  Future<void> _sendRequestToEsp32() async {
    try {
      final response = await http.get(Uri.parse('$esp32Url/levantarBarra'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Precaución Barra Bajando')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al contactar el ESP32')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isScanning) return; // Si el escaneo está bloqueado, no hacer nada.

      setState(() {
        result = scanData;
      });

      // Validar el resultado del código QR
      if (result?.code != null && result!.code!.contains(validCodeFragment)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ingreso Autorizado')),
        );
        await _sendRequestToEsp32();

        // Bloquear el escaneo por 10 segundos
        setState(() {
          isScanning = false;
        });

        // Configurar un temporizador de 10 segundos
        _scanCooldownTimer = Timer(Duration(seconds: 10), () {
          setState(() {
            isScanning = true; // Rehabilitar el escaneo después de 10 segundos
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ingreso no autorizado')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanea tu QR de ingreso'),
      ),
      body: Stack(
        children: [
          // Cámara con QRView
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          // Resultado sobrepuesto
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.all(16),
              child: Text(
                result != null
                    ? 'Resultado: ${result!.code}'
                    : 'Escanea un código QR',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
