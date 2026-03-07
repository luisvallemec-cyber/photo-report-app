class WatermarkConfig {
  String text;
  String color;
  double fontSize;
  double opacity;

  WatermarkConfig({required this.text, required this.color, required this.fontSize, required this.opacity});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'color': color,
      'fontSize': fontSize,
      'opacity': opacity,
    };
  }

  factory WatermarkConfig.fromMap(Map<String, dynamic> map) {
    return WatermarkConfig(
      text: map['text'] ?? '',
      color: map['color'] ?? '',
      fontSize: map['fontSize']?.toDouble() ?? 12.0,
      opacity: map['opacity']?.toDouble() ?? 1.0,
    );
  }
}
