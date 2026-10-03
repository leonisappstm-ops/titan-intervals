import 'package:flutter/material.dart';

/// Authentic 4-color Google "G" Logo
class GoogleIconWidget extends StatelessWidget {
  final double size;

  const GoogleIconWidget({
    super.key,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Blue #4285F4
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final pathBlue = Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.26)
      ..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(15.71, 20.34)
      ..lineTo(19.28, 20.34)
      ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)
      ..close();
    canvas.drawPath(pathBlue, paintBlue);

    // Green #34A853
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final pathGreen = Path()
      ..moveTo(12.0, 23.0)
      ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)
      ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.09)
      ..lineTo(2.18, 14.09)
      ..lineTo(2.18, 16.94)
      ..cubicTo(3.99, 20.53, 7.7, 23.0, 12.0, 23.0)
      ..close();
    canvas.drawPath(pathGreen, paintGreen);

    // Yellow #FBBC05
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final pathYellow = Path()
      ..moveTo(5.84, 14.09)
      ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12.0)
      ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
      ..lineTo(5.84, 7.06)
      ..lineTo(2.18, 7.06)
      ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
      ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.94)
      ..lineTo(5.84, 14.09)
      ..close();
    canvas.drawPath(pathYellow, paintYellow);

    // Red #EA4335
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final pathRed = Path()
      ..moveTo(12.0, 5.38)
      ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
      ..cubicTo(7.7, 1.0, 3.99, 3.47, 2.18, 7.06)
      ..lineTo(5.84, 9.9)
      ..cubicTo(6.71, 7.3, 9.14, 5.38, 12.0, 5.38)
      ..close();
    canvas.drawPath(pathRed, paintRed);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Authentic Facebook "f" Logo Badge
class FacebookIconWidget extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const FacebookIconWidget({
    super.key,
    this.size = 22,
    this.backgroundColor = const Color(0xFF1877F2),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FacebookLogoPainter(
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      ),
    );
  }
}

class _FacebookLogoPainter extends CustomPainter {
  final Color backgroundColor;
  final Color iconColor;

  _FacebookLogoPainter({
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Background circular badge
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(12, 12), 12, bgPaint);

    // Official Facebook "f" path
    final fPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    final fPath = Path()
      ..moveTo(16.5, 12.0)
      ..lineTo(13.8, 12.0)
      ..lineTo(13.8, 24.0)
      ..lineTo(9.5, 24.0)
      ..lineTo(9.5, 12.0)
      ..lineTo(7.5, 12.0)
      ..lineTo(7.5, 8.5)
      ..lineTo(9.5, 8.5)
      ..lineTo(9.5, 6.2)
      ..cubicTo(9.5, 3.8, 10.9, 2.0, 14.5, 2.0)
      ..lineTo(16.5, 2.0)
      ..lineTo(16.5, 5.3)
      ..lineTo(15.0, 5.3)
      ..cubicTo(13.8, 5.3, 13.5, 5.8, 13.5, 6.7)
      ..lineTo(13.5, 8.5)
      ..lineTo(16.5, 8.5)
      ..close();

    // Clip to the circular badge bounds
    canvas.save();
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, 24, 24)));
    canvas.drawPath(fPath, fPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
