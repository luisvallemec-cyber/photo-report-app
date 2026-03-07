import 'package:flutter/material.dart';

class DrawingCanvasWidget extends StatefulWidget {
  final Image image;
  DrawingCanvasWidget({required this.image});

  @override
  _DrawingCanvasWidgetState createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  List<Offset?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanEnd: (details) {
              points.add(null);
            },
            child: CustomPaint(
              painter: DrawingPainter(points, selectedColor, strokeWidth),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.image.image,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ...colorOptions(),
            strokeWidthSelector(),
          ],
        ),
      ],
    );
  }

  List<Widget> colorOptions() {
    return [
      GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = Colors.red;
          });
        },
        child: CircleAvatar(backgroundColor: Colors.red),
      ),
      GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = Colors.green;
          });
        },
        child: CircleAvatar(backgroundColor: Colors.green),
      ),
      GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = Colors.blue;
          });
        },
        child: CircleAvatar(backgroundColor: Colors.blue),
      ),
    ];
  }

  Widget strokeWidthSelector() {
    return DropdownButton<double>(
      value: strokeWidth,
      items: [5.0, 10.0, 15.0, 20.0]
          .map((value) => DropdownMenuItem<double>(
                value: value,
                child: Text('${value.toString()}'),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          strokeWidth = value!;
        });
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  DrawingPainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return true;
  }
}