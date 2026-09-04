import 'package:flutter/material.dart';

/// Ícone colorido do Google desenhado via CustomPainter.
/// Fiel ao logo oficial: arco dividido em 4 cores + barra horizontal azul do "G".
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - size.width * 0.09;
    final strokeW = size.width * 0.2;

    void drawArcSegment(double start, double sweep, Color color) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt,
      );
    }

    const pi = 3.14159265;
    // Quadrantes: vermelho (superior direito), amarelo (inferior direito),
    // verde (inferior esquerdo), azul (superior esquerdo)
    drawArcSegment(-pi / 2, pi / 2, const Color(0xFFEA4335));  // vermelho
    drawArcSegment(0, pi / 2, const Color(0xFFFBBC05));         // amarelo
    drawArcSegment(pi / 2, pi / 2, const Color(0xFF34A853));    // verde
    drawArcSegment(pi, pi / 2, const Color(0xFF4285F4));        // azul

    // Barra horizontal do "G" (azul)
    final barH = size.height * 0.18;
    final barY = cy - barH / 2;
    final barX = cx - size.width * 0.04;
    final barW = size.width / 2 + size.width * 0.09 + strokeW / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barW, barH),
        Radius.circular(barH / 2),
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
