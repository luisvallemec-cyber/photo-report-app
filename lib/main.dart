import 'package:flutter/material.dart';

void main() {
  runApp(PhotoReportApp());
}

class PhotoReportApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Report App',
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
        title: Text('Photo Report'),
      ),
      body: Center(
        child: Text('Welcome to the Photo Report App!'),
      ),
    );
  }
}