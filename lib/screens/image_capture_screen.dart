import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  void _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = pickedFile;
    });
  }

  void _selectImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Image')), 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[ 
          if (_image != null) 
            Image.file(File(_image!.path)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _captureImage,
                child: Text('Capture from Camera'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _selectImageFromGallery,
                child: Text('Select from Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}