import 'package:flutter/material.dart';

class BirdLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color =
              Colors
                  .white // White color for the bird
          ..style = PaintingStyle.fill;

    // Drawing bird body (circle)
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, paint);

    // Drawing wings (two paths)
    Path leftWing =
        Path()
          ..moveTo(size.width / 2, size.height / 2 - 40)
          ..lineTo(size.width / 2 - 60, size.height / 2 - 100)
          ..lineTo(size.width / 2, size.height / 2 - 80)
          ..close();

    Path rightWing =
        Path()
          ..moveTo(size.width / 2, size.height / 2 - 40)
          ..lineTo(size.width / 2 + 60, size.height / 2 - 100)
          ..lineTo(size.width / 2, size.height / 2 - 80)
          ..close();

    paint.color = Colors.white.withOpacity(0.6); // Slightly transparent wings
    canvas.drawPath(leftWing, paint);
    canvas.drawPath(rightWing, paint);

    // Drawing bird tail (simple path)
    Path tail =
        Path()
          ..moveTo(size.width / 2, size.height / 2 + 40)
          ..lineTo(size.width / 2 - 30, size.height / 2 + 70)
          ..lineTo(size.width / 2 + 30, size.height / 2 + 70)
          ..close();

    paint.color = Colors.white;
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint
  }
}
