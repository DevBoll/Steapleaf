import 'package:flutter/material.dart';

/// Quadratischer Slider-Thumb als Ersatz für den runden Standard-Thumb.
class SquareSliderThumbShape extends SliderComponentShape {
  const SquareSliderThumbShape({this.size = 20.0});

  final double size;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(size, size);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.black
      ..style = PaintingStyle.fill;

    final double half = size / 2;
    context.canvas.drawRect(
      Rect.fromCenter(center: center, width: size, height: size),
      paint,
    );

    // Disabled-State: leicht ausgegraut
    if (enableAnimation.value < 1.0) {
      final Paint overlayPaint = Paint()
        ..color = Colors.white.withValues(alpha: 1 - enableAnimation.value)
        ..style = PaintingStyle.fill;
      context.canvas.drawRect(
        Rect.fromCenter(center: center, width: size, height: size),
        overlayPaint,
      );
    }
  }
}
