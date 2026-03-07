import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

class ImageEditorScreen extends StatefulWidget {
  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  // Example image data and drawing tools state
  Image? _image;
  Color _drawColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Editor'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Save logic here
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              // Cancel logic here
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _image != null
                  ? Image(image: _image!.image)
                  : Center(child: Text('No image selected')), // Add drawing canvas here
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.palette),
                onPressed: () {
                  // Change color logic here
                },
              ),
              // Add more drawing tool buttons here
            ],
          ),
        ],
      ),
    );
  }
}