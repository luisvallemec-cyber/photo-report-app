import 'package:flutter/material.dart';
import 'widgets/category_tree_widget.dart';

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
  static final List<CategoryTreeNode> _categories = [
    CategoryTreeNode(
      title: 'Estructuras',
      children: [
        CategoryTreeNode(title: 'Cimientos'),
        CategoryTreeNode(
          title: 'Paredes',
          children: [
            CategoryTreeNode(title: 'Paredes interiores'),
            CategoryTreeNode(title: 'Paredes exteriores'),
          ],
        ),
        CategoryTreeNode(title: 'Techos'),
      ],
    ),
    CategoryTreeNode(
      title: 'Instalaciones',
      children: [
        CategoryTreeNode(title: 'Eléctricas'),
        CategoryTreeNode(title: 'Hidráulicas'),
        CategoryTreeNode(title: 'Sanitarias'),
      ],
    ),
    CategoryTreeNode(
      title: 'Acabados',
      children: [
        CategoryTreeNode(title: 'Pintura'),
        CategoryTreeNode(title: 'Pisos'),
        CategoryTreeNode(title: 'Ventanas y puertas'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Report'),
      ),
      body: CategoryTreeWidget(nodes: _categories),
    );
  }
}