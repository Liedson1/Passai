import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Painter customizado que desenha o pino em formato de gota/agulha
/// garantindo que a ponta inferior termine exatamente no pixel (w/2, h)
class PinoTeardropPainter extends CustomPainter {
  const PinoTeardropPainter({
    required this.cor,
    required this.corBorda,
  });

  final Color cor;
  final Color corBorda;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;

    // Sombra suave sob a ponta do pino (web-safe, sem shader MaskFilter)
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h - 0.5), width: 8, height: 3),
      shadowPaint,
    );

    // Caminho da agulha em gota com ponta inferior exata
    final path = ui.Path();
    path.moveTo(w / 2, h); // Ponta inferior exata
    path.cubicTo(
      w * 0.15, h * 0.55,
      0, r * 1.1,
      0, r,
    );
    path.arcToPoint(
      Offset(w, r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.cubicTo(
      w, r * 1.1,
      w * 0.85, h * 0.55,
      w / 2, h, // Fecha exatamente na ponta inferior
    );
    path.close();

    // Preenchimento
    final paintFill = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFill);

    // Borda branca de acabamento
    final paintStroke = Paint()
      ..color = corBorda
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paintStroke);

    // Miolo central branco
    final paintDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, r), r * 0.38, paintDot);
  }

  @override
  bool shouldRepaint(covariant PinoTeardropPainter oldDelegate) =>
      oldDelegate.cor != cor || oldDelegate.corBorda != corBorda;
}
