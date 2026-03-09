import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/photo_item.dart';

class GalleryScreen extends StatefulWidget {
  /// When [categoryId] is provided, only photos from that category are shown.
  /// When null, all photos are shown grouped by category.
  final String? categoryId;

  const GalleryScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<PhotoItem> _photos = [];
  Map<String, String> _categoryNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<PhotoItem> photos;
    if (widget.categoryId != null) {
      photos = await DatabaseHelper.instance
          .getPhotosByCategory(widget.categoryId!);
    } else {
      photos = await DatabaseHelper.instance.getAllPhotos();
    }
    final categories = await DatabaseHelper.instance.getAllCategories();
    final Map<String, String> nameMap = {
      for (final c in categories) c.id: c.name
    };
    if (mounted) {
      setState(() {
        _photos = photos;
        _categoryNames = nameMap;
        _loading = false;
      });
    }
  }

  Future<void> _deletePhoto(PhotoItem photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Foto'),
        content: const Text('¿Estás seguro de que deseas eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deletePhoto(photo.id);
      // Delete the file from disk if it exists
      final file = File(photo.imagePath);
      if (await file.exists()) await file.delete();
      await _loadData();
    }
  }

  void _viewPhoto(PhotoItem photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewScreen(photo: photo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryId != null
        ? 'Galería de Rama'
        : 'Galería General';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay fotos todavía.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    final catName =
                        _categoryNames[photo.categoryId] ?? 'Sin categoría';
                    return GestureDetector(
                      onTap: () => _viewPhoto(photo),
                      onLongPress: () => _deletePhoto(photo),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(photo.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 3),
                              child: Text(
                                catName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ── Full-screen photo viewer ──────────────────────────────────────────────────

class _PhotoViewScreen extends StatelessWidget {
  final PhotoItem photo;

  const _PhotoViewScreen({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          photo.createdAt.toLocal().toString().substring(0, 16),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(photo.imagePath),
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

