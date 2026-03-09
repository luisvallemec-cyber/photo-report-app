import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database_helper.dart';
import '../models/photo_item.dart';

class ImageCaptureScreen extends StatefulWidget {
  final String categoryId;

  const ImageCaptureScreen({Key? key, required this.categoryId})
      : super(key: key);

  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _DrawingPreviewScreen(
            imagePath: pickedFile.path,
            categoryId: widget.categoryId,
          ),
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _DrawingPreviewScreen(
            imagePath: pickedFile.path,
            categoryId: widget.categoryId,
          ),
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar Foto')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Tomar Foto con Cámara',
                      style: TextStyle(fontSize: 16)),
                ),
                onPressed: _captureFromCamera,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library, size: 28),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Elegir de Galería',
                      style: TextStyle(fontSize: 16)),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                onPressed: _pickFromGallery,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Drawing preview screen ────────────────────────────────────────────────────

class _DrawingPreviewScreen extends StatefulWidget {
  final String imagePath;
  final String categoryId;

  const _DrawingPreviewScreen(
      {Key? key, required this.imagePath, required this.categoryId})
      : super(key: key);

  @override
  _DrawingPreviewScreenState createState() => _DrawingPreviewScreenState();
}

class _DrawingPreviewScreenState extends State<_DrawingPreviewScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  List<_Stroke> _strokes = [];
  List<Offset?> _currentStroke = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 4.0;
  bool _saving = false;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.white,
  ];

  void _onPanStart(DragStartDetails d) {
    _currentStroke = [d.localPosition];
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _currentStroke.add(d.localPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails d) {
    _strokes.add(_Stroke(
      points: List.of(_currentStroke),
      color: _selectedColor,
      width: _strokeWidth,
    ));
    _currentStroke = [];
    setState(() {});
  }

  void _undoLastStroke() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.removeLast());
    }
  }

  void _clearAll() {
    setState(() {
      _strokes = [];
      _currentStroke = [];
    });
  }

  Future<void> _savePhoto() async {
    setState(() => _saving = true);
    try {
      // Capture the composite widget (image + drawing) as bytes
      final RenderRepaintBoundary boundary = _repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to permanent storage
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'photo_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = p.join(dir.path, fileName);
      await File(savedPath).writeAsBytes(pngBytes);

      // Persist in database
      final item = PhotoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: widget.categoryId,
        imagePath: savedPath,
        createdAt: DateTime.now(),
      );
      await DatabaseHelper.instance.insertPhoto(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto guardada correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Foto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoLastStroke,
            tooltip: 'Deshacer',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
            tooltip: 'Limpiar todo',
          ),
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _savePhoto,
                  tooltip: 'Guardar',
                ),
        ],
      ),
      body: Column(
        children: [
          // ── Drawing canvas ─────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: RepaintBoundary(
                key: _repaintKey,
                child: CustomPaint(
                  painter: _DrawingPainter(
                    imagePath: widget.imagePath,
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                    currentColor: _selectedColor,
                    currentWidth: _strokeWidth,
                  ),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // ── Toolbar ────────────────────────────────────────────────────
          Container(
            color: Colors.grey[900],
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Color selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _colorOptions.map((color) {
                    final selected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: selected ? 32 : 26,
                        height: selected ? 32 : 26,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.grey,
                            width: selected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Stroke width slider
                Row(
                  children: [
                    const Icon(Icons.line_weight,
                        color: Colors.white, size: 18),
                    Expanded(
                      child: Slider(
                        value: _strokeWidth,
                        min: 1.0,
                        max: 20.0,
                        divisions: 19,
                        label: _strokeWidth.round().toString(),
                        onChanged: (v) =>
                            setState(() => _strokeWidth = v),
                      ),
                    ),
                    Text(
                      '${_strokeWidth.round()}px',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Foto'),
                    onPressed: _saving ? null : _savePhoto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawing data models ───────────────────────────────────────────────────────

class _Stroke {
  final List<Offset?> points;
  final Color color;
  final double width;

  _Stroke({required this.points, required this.color, required this.width});
}

class _DrawingPainter extends CustomPainter {
  final String imagePath;
  final List<_Stroke> strokes;
  final List<Offset?> currentStroke;
  final Color currentColor;
  final double currentWidth;

  _DrawingPainter({
    required this.imagePath,
    required this.strokes,
    required this.currentStroke,
    required this.currentColor,
    required this.currentWidth,
  });

  void _paintStroke(Canvas canvas, List<Offset?> points, Color color,
      double width) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool started = false;
    for (final point in points) {
      if (point == null) {
        started = false;
        continue;
      }
      if (!started) {
        path.moveTo(point.dx, point.dy);
        started = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke.points, stroke.color, stroke.width);
    }
    if (currentStroke.isNotEmpty) {
      _paintStroke(
          canvas, currentStroke, currentColor, currentWidth);
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => true;
}
