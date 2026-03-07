import 'package:flutter/material.dart';

class WatermarkConfigDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Watermark Configuration'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Watermark Text'),
            ),
            ColorPickerDialog(),
            Slider(
              value: 12.0,
              min: 8.0,
              max: 36.0,
              divisions: 28,
              label: 'Font Size',
              onChanged: (value) {},
            ),
            Slider(
              value: 0.5,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: 'Opacity',
              onChanged: (value) {},
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ColorPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open color picker
      },
      child: Container(
        height: 50,
        color: Colors.blue,
        child: Center(child: Text('Pick Watermark Color', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
