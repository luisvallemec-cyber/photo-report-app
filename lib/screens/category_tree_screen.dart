import 'package:flutter/material.dart';

class CategoryTreeScreen extends StatefulWidget {
  @override
  _CategoryTreeScreenState createState() => _CategoryTreeScreenState();
}

class _CategoryTreeScreenState extends State<CategoryTreeScreen> {
  List<Category> categories = [...]; // Add your categories here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Tree'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add category button functionality here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _buildCategoryTree(categories),
      ),
    );
  }

  Widget _buildCategoryTree(List<Category> categories) {
    return ExpansionTile(
      title: Text(categories[0].name), // Example; modify as needed
      children: categories.map((category) {
        return ListTile(
          title: Text(category.name),
        );
      }).toList(),
    );
  }
}

class Category {
  final String name;

  Category(this.name);
}