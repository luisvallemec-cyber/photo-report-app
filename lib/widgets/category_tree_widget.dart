import 'package:flutter/material.dart';

class CategoryTreeNode {
  final String title;
  final List<CategoryTreeNode> children;

  CategoryTreeNode({required this.title, this.children = const []});
}

class CategoryTreeWidget extends StatefulWidget {
  final List<CategoryTreeNode> nodes;

  const CategoryTreeWidget({Key? key, required this.nodes}) : super(key: key);

  @override
  _CategoryTreeWidgetState createState() => _CategoryTreeWidgetState();
}

class _CategoryTreeWidgetState extends State<CategoryTreeWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.nodes.map((node) => _buildTreeNode(node)).toList(),
    );
  }

  Widget _buildTreeNode(CategoryTreeNode node) {
    return ExpansionTile(
      title: Text(node.title),
      children: node.children.map((child) => _buildTreeNode(child)).toList(),
    );
  }
}