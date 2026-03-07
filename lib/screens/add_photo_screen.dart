import 'package:image_picker/image_picker.dart';
import 'package:your_project/models/category.dart'; // Update with the correct path

class AddPhotoScreen {
  final ImagePicker _picker = ImagePicker();

  Future<void> capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // Handle the photo captured from camera
    }
  }

  Future<void> pickPhotoFromGallery() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      // Handle the photo selected from gallery
    }
  }

  Future<void> pickMultiplePhotos() async {
    final List<XFile> photos = await _picker.pickMultiImage();
    if (photos.isNotEmpty) {
      // Handle the multiple photos selected
    }
  }
}