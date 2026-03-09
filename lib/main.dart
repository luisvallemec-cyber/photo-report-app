import 'package:flutter/material.dart';

void main() {
  runApp(PhotoReportApp());
}

class PhotoReportApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reporte Fotográfico',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte Fotográfico'),
      ),
      body: Center(
        child: Text('¡Sí! Me puedes pasar todo el código.'),
      ),
    );
  }
}
