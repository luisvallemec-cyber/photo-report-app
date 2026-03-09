import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import 'gallery_screen.dart';
import 'image_capture_screen.dart';

class CategoryTreeScreen extends StatefulWidget {
  const CategoryTreeScreen({Key? key}) : super(key: key);

  @override
  _CategoryTreeScreenState createState() => _CategoryTreeScreenState();
}

class _CategoryTreeScreenState extends State<CategoryTreeScreen> {
  List<Category> _allCategories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseHelper.instance.getAllCategories();
    if (mounted) {
      setState(() {
        _allCategories = cats;
        _loading = false;
      });
    }
  }

  List<Category> _rootCategories() =>
      _allCategories.where((c) => c.parentId == null).toList();

  List<Category> _childrenOf(String parentId) =>
      _allCategories.where((c) => c.parentId == parentId).toList();

  Future<void> _showAddBranchDialog({String? parentId}) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentId == null
            ? 'Nueva Rama Principal'
            : 'Nueva Sub-Rama'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre de la rama',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final newCat = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: controller.text.trim(),
        parentId: parentId,
      );
      await DatabaseHelper.instance.insertCategory(newCat);
      await _loadCategories();
    }
  }

  Future<void> _deleteCategory(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Rama'),
        content: const Text(
            'Se eliminarán también todas las sub-ramas y fotos asociadas. ¿Continuar?'),
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
      await DatabaseHelper.instance.deleteCategory(id);
      await _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Árbol de Actividades'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _rootCategories().isEmpty
                      ? const Center(
                          child: Text(
                            'No hay ramas aún.\nPresiona el botón para agregar una.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView(
                          children: _rootCategories()
                              .map((cat) => _BranchNode(
                                    category: cat,
                                    childrenOf: _childrenOf,
                                    onRefresh: _loadCategories,
                                    onAddSubBranch: (parentId) =>
                                        _showAddBranchDialog(
                                            parentId: parentId),
                                    onDelete: _deleteCategory,
                                    depth: 0,
                                  ))
                              .toList(),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Agregar Rama Principal',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showAddBranchDialog(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Recursive branch node ────────────────────────────────────────────────────

class _BranchNode extends StatefulWidget {
  final Category category;
  final List<Category> Function(String) childrenOf;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String parentId) onAddSubBranch;
  final Future<void> Function(String id) onDelete;
  final int depth;

  const _BranchNode({
    Key? key,
    required this.category,
    required this.childrenOf,
    required this.onRefresh,
    required this.onAddSubBranch,
    required this.onDelete,
    required this.depth,
  }) : super(key: key);

  @override
  _BranchNodeState createState() => _BranchNodeState();
}

class _BranchNodeState extends State<_BranchNode> {
  bool _expanded = false;
  List<_PhotoPreview> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final items = await DatabaseHelper.instance
        .getPhotosByCategory(widget.category.id);
    if (mounted) {
      setState(() {
        _photos = items
            .map((p) => _PhotoPreview(path: p.imagePath, id: p.id))
            .toList();
      });
    }
  }

  Future<void> _takePhoto() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ImageCaptureScreen(categoryId: widget.category.id),
      ),
    );
    await _loadPhotos();
  }

  Future<void> _openGallery() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryScreen(categoryId: widget.category.id),
      ),
    );
    await _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.childrenOf(widget.category.id);
    final indent = widget.depth * 16.0;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: widget.depth == 0 ? 3 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Branch header ──────────────────────────────────────────
            ListTile(
              leading: Icon(
                _expanded ? Icons.folder_open : Icons.folder,
                color: widget.depth == 0 ? Colors.blue : Colors.orange,
              ),
              title: Text(
                widget.category.name,
                style: TextStyle(
                  fontWeight: widget.depth == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: widget.depth == 0 ? 16 : 14,
                ),
              ),
              subtitle: Text(
                '${_photos.length} foto(s)',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => widget.onDelete(widget.category.id),
                tooltip: 'Eliminar rama',
              ),
              onTap: () {
                setState(() => _expanded = !_expanded);
              },
            ),

            // ── Expanded content ───────────────────────────────────────
            if (_expanded) ...[
              // Photo thumbnails
              if (_photos.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _photos.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(_photos[i].path),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_photos.isNotEmpty) const SizedBox(height: 6),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 6.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Agregar Sub-Rama',
                      color: Colors.blue,
                      onPressed: () =>
                          widget.onAddSubBranch(widget.category.id),
                    ),
                    _ActionButton(
                      icon: Icons.camera_alt,
                      label: 'Tomar Foto',
                      color: Colors.teal,
                      onPressed: _takePhoto,
                    ),
                    _ActionButton(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      color: Colors.green,
                      onPressed: _openGallery,
                    ),
                  ],
                ),
              ),

              // Sub-branches
              if (children.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    children: children
                        .map((child) => _BranchNode(
                              key: ValueKey(child.id),
                              category: child,
                              childrenOf: widget.childrenOf,
                              onRefresh: widget.onRefresh,
                              onAddSubBranch: widget.onAddSubBranch,
                              onDelete: widget.onDelete,
                              depth: widget.depth + 1,
                            ))
                        .toList(),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview {
  final String path;
  final String id;
  _PhotoPreview({required this.path, required this.id});
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      onPressed: onPressed,
    );
  }
}
