import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  TextEditingController _outputController = TextEditingController();
  final String esp32Url =
      'http://192.168.175.118'; // Reemplazar con la IP del ESP32
  final String validCodeFragment = "codigoEntrada";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _outputController.dispose();
    super.dispose();
  }

  void _startScanning() {
    Future.delayed(Duration.zero, _scan);
  }

  Future<void> _scan() async {
    _timer?.cancel();

    var status = await Permission.camera.request();
    if (status.isGranted) {
      String? barcode = await scanner.scan();
      if (barcode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se escaneó el QR')),
        );
      } else {
        setState(() {
          _outputController.text = barcode;
        });

        // Verificar si el texto contiene el fragmento válido
        if (barcode.contains(validCodeFragment)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ingreso Autorizado')),
          );
          await _sendRequestToEsp32();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ingreso no autorizado')),
          );
        }
      }

      _timer = Timer(Duration(seconds: 2), _scan);
    } else if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cámara: permiso denegado')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _outputController,
              readOnly: true,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Resultado del QR',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
