import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ImageStorageService {
  // Save image to device storage
  Future<String> saveImageToDevice(String imagePath) async {
    // Logic to save the image to device storage
    // Example: Copying the file to a specific directory
    final directory = Directory('/path/to/storage');
    final File imageFile = File(imagePath);
    await imageFile.copy('${directory.path}/image_${DateTime.now()}.png');
    return 'Image saved to device storage!';
  }

  // Save image to database
  Future<void> saveImageToDatabase(String imagePath) async {
    // Logic to save the image path or data to the database
    final Database db = await _initializeDatabase();
    await db.insert('images', {'path': imagePath});
  }

  Future<Database> _initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'images.db');
    return await openDatabase(path, version: 1, 
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE images (id INTEGER PRIMARY KEY, path TEXT)');
      },
    );
  }
}