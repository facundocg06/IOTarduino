import 'package:flutter/material.dart';
import 'qrscan.dart'; // Archivo donde estará la lógica del escáner

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRScanner(),
    );
  }
}
