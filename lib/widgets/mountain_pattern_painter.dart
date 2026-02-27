import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pattern painter decorativo con montagne, alberi stilizzati e stelle alpine.
/// Usato come sfondo per le card di condivisione e il passaporto dei rifugi.
class MountainPatternPainter extends CustomPainter {
  final Color color;

  const MountainPatternPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Disegna sagome di montagne in linea
    final mountainPath = Path();
    mountainPath.moveTo(0, size.height * 0.6);

    // Profilo montagne irregolare
    for (var i = 0; i < 8; i++) {
      final x = (size.width / 8) * i;
      final peakHeight = size.height * (0.3 + (i % 3) * 0.15);
      mountainPath.lineTo(x, peakHeight);
      mountainPath.lineTo(x + size.width / 16, size.height * 0.6);
    }
    canvas.drawPath(mountainPath, paint);

    // Disegna piccoli alberi stilizzati sparsi
    final treePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 15; i++) {
      final x = (i * 87.3) % size.width;
      final y = (i * 112.7) % size.height;

      // Triangolo per albero
      final treePath = Path();
      treePath.moveTo(x, y);
      treePath.lineTo(x - 8, y + 20);
      treePath.lineTo(x + 8, y + 20);
      treePath.close();
      canvas.drawPath(treePath, treePaint);

      // Tronco
      canvas.drawRect(Rect.fromLTWH(x - 2, y + 20, 4, 8), treePaint);
    }

    // Disegna stelle alpine (fiori) in alcuni punti
    final flowerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 12; i++) {
      final x = (i * 103.5) % size.width;
      final y = (i * 141.2) % size.height;

      // Stella a 6 punte
      for (var j = 0; j < 6; j++) {
        final angle = (j * 60) * 3.14159 / 180;
        final endX = x + 6 * math.cos(angle);
        final endY = y + 6 * math.sin(angle);
        canvas.drawCircle(Offset(endX, endY), 2, flowerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(MountainPatternPainter oldDelegate) =>
      color != oldDelegate.color;
}
