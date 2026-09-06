import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passai/core/theme/app_colors.dart';

enum PassaiLogoVariant {
  circular,
  horizontal,
  horizontalTerracota,
  van,
  text,
}

/// Exibe a logo oficial do Passaí renderizada 100% de forma nativa em código Flutter:
/// - A van com marcador de GPS é desenhada via [PassaiVanIcon] (vetor nativo no canvas).
/// - A tipografia PASSAÍ é renderizada nativamente com a fonte oficial Jua (do Figma).
/// - Zero dependência de imagens rasterizadas, garantindo nitidez absoluta em qualquer tela.
class PassaiLogo extends StatelessWidget {
  const PassaiLogo({
    super.key,
    this.size = 40,
    this.withShadow = true,
    this.variant = PassaiLogoVariant.circular,
    this.height,
    this.color,
  });

  /// Construtor de conveniência para a logo horizontal (Van nativa + PASSAÍ em texto nativo).
  const PassaiLogo.horizontal({
    super.key,
    double height = 30,
    this.withShadow = false,
    this.color,
  })  : size = height,
        height = height,
        variant = PassaiLogoVariant.horizontal;

  /// Construtor de conveniência para a logo horizontal completa com fundo cápsula terracota.
  const PassaiLogo.horizontalTerracota({
    super.key,
    double height = 36,
    this.withShadow = false,
    this.color,
  })  : size = height,
        height = height,
        variant = PassaiLogoVariant.horizontalTerracota;

  /// Alias de conveniência para a logo horizontal com fundo terracota.
  const PassaiLogo.terracota({
    super.key,
    double height = 36,
    this.withShadow = false,
    this.color,
  })  : size = height,
        height = height,
        variant = PassaiLogoVariant.horizontalTerracota;

  /// Construtor de conveniência para o ícone da van isolado em vetor nativo.
  const PassaiLogo.van({
    super.key,
    double size = 30,
    this.withShadow = false,
    this.color,
  })  : size = size,
        height = size,
        variant = PassaiLogoVariant.van;

  /// Construtor de conveniência para o wordmark PASSAÍ isolado em texto nativo.
  const PassaiLogo.text({
    super.key,
    double height = 26,
    this.withShadow = false,
    this.color,
  })  : size = height,
        height = height,
        variant = PassaiLogoVariant.text;

  /// Diâmetro da logo circular ou altura base da logo horizontal / van / text.
  final double size;

  /// Altura explícita para variante horizontal ou text.
  final double? height;

  /// Se verdadeiro, aplica uma sombra sutil ao redor da logo circular.
  final bool withShadow;

  /// Cor opcional para colorir a van e o texto (padrão é branco puro).
  final Color? color;

  /// Variante visual da logo.
  final PassaiLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final h = height ?? size;
    final effectiveColor = color ?? Colors.white;

    if (variant == PassaiLogoVariant.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PassaiVanIcon(
            height: h,
            color: effectiveColor,
          ),
          SizedBox(width: h * 0.28),
          Text(
            'PASSAÍ',
            style: GoogleFonts.jua(
              fontSize: h * 0.75,
              letterSpacing: 1.0,
              color: effectiveColor,
              height: 1.0,
            ),
          ),
        ],
      );
    }

    if (variant == PassaiLogoVariant.horizontalTerracota) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: h * 0.32, vertical: h * 0.16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(h * 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PassaiVanIcon(
              height: h * 0.72,
              color: Colors.white,
            ),
            SizedBox(width: h * 0.2),
            Text(
              'PASSAÍ',
              style: GoogleFonts.jua(
                fontSize: h * 0.54,
                letterSpacing: 1.0,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    if (variant == PassaiLogoVariant.van) {
      return PassaiVanIcon(
        height: h,
        color: effectiveColor,
      );
    }

    if (variant == PassaiLogoVariant.text) {
      return Text(
        'PASSAÍ',
        style: GoogleFonts.jua(
          fontSize: h * 0.88,
          letterSpacing: 1.0,
          color: effectiveColor,
          height: 1.0,
        ),
      );
    }

    // Variante Circular (Badge) com fundo terracota
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: size * 0.18,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: PassaiVanIcon(
        height: size * 0.46,
        color: Colors.white,
      ),
    );
  }
}

/// Widget vetorial puro que desenha a van oficial com o marcador de GPS
/// diretamente no Canvas do Flutter com aceleração de hardware.
class PassaiVanIcon extends StatelessWidget {
  const PassaiVanIcon({
    super.key,
    required this.height,
    this.color = Colors.white,
  });

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Proporção oficial do vetor original (largura 438, altura 275)
    final width = height * (438.0 / 275.0);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: PassaiVanPainter(color: color),
      ),
    );
  }
}

/// CustomPainter que renderiza os caminhos vetoriais da van e do pino de localização
class PassaiVanPainter extends CustomPainter {
  const PassaiVanPainter({this.color = Colors.white});

  final Color color;

  static final Path _cachedVanPath = _buildVanPath();

  static Path _buildVanPath() {
    final path = Path()..fillType = PathFillType.evenOdd;
    // Vector
    path.moveTo(110.81, 201.88);
    path.cubicTo(118.21, 207.15, 123.58, 213.10, 126.69, 221.69);
    path.cubicTo(128.19, 225.91, 128.19, 225.91, 130.00, 230.00);
    path.cubicTo(130.12, 231.98, 130.18, 233.96, 130.19, 235.94);
    path.cubicTo(130.20, 237.00, 130.22, 238.06, 130.23, 239.15);
    path.cubicTo(130.00, 242.00, 130.00, 242.00, 128.00, 245.00);
    path.cubicTo(127.42, 246.37, 126.86, 247.74, 126.31, 249.12);
    path.cubicTo(121.72, 259.55, 114.27, 267.10, 103.69, 271.31);
    path.cubicTo(92.71, 274.91, 82.71, 274.75, 72.20, 269.64);
    path.cubicTo(62.70, 264.19, 55.03, 255.90, 51.46, 245.36);
    path.cubicTo(49.43, 235.00, 50.60, 224.12, 56.00, 215.00);
    path.cubicTo(68.53, 196.57, 91.09, 189.27, 110.81, 201.88);
    path.close();
    // Vector_2
    path.moveTo(135.81, 65.99);
    path.cubicTo(137.76, 65.93, 137.76, 65.93, 139.75, 65.88);
    path.cubicTo(148.96, 65.59, 154.21, 72.14, 158.69, 79.38);
    path.cubicTo(164.00, 89.44, 169.00, 102.50, 174.50, 113.40);
    path.cubicTo(184.22, 131.46, 194.53, 149.02, 205.69, 166.25);
    path.cubicTo(206.65, 167.75, 206.65, 167.75, 207.63, 169.28);
    path.cubicTo(216.83, 185.17, 227.56, 184.13, 235.65, 170.52);
    path.cubicTo(236.18, 169.63, 236.70, 168.75, 237.24, 167.84);
    path.cubicTo(237.80, 166.90, 238.36, 165.97, 238.94, 165.00);
    path.cubicTo(239.51, 164.03, 240.09, 163.07, 240.68, 162.07);
    path.cubicTo(244.94, 154.92, 249.26, 147.80, 253.66, 140.74);
    path.cubicTo(263.68, 124.54, 273.50, 104.15, 282.00, 87.65);
    path.cubicTo(285.35, 81.15, 285.50, 78.00, 287.60, 72.33);
    path.cubicTo(287.86, 71.17, 288.13, 70.02, 288.40, 68.83);
    path.cubicTo(288.70, 67.52, 288.70, 67.52, 289.00, 66.19);
    path.cubicTo(303.61, 66.09, 318.23, 66.02, 332.84, 65.98);
    path.cubicTo(339.62, 65.96, 346.41, 65.93, 353.19, 65.89);
    path.cubicTo(359.74, 65.84, 366.29, 65.82, 372.84, 65.81);
    path.cubicTo(375.34, 65.80, 377.83, 65.79, 380.33, 65.76);
    path.cubicTo(383.83, 65.74, 387.33, 65.73, 390.83, 65.73);
    path.cubicTo(392.38, 65.71, 392.38, 65.71, 393.96, 65.69);
    path.cubicTo(400.20, 65.73, 403.89, 66.53, 409.00, 70.19);
    path.cubicTo(425.97, 87.59, 427.77, 125.84, 428.43, 148.90);
    path.cubicTo(428.50, 151.14, 428.58, 153.37, 428.65, 155.61);
    path.cubicTo(428.77, 159.09, 428.88, 162.56, 428.97, 166.04);
    path.cubicTo(429.07, 169.43, 429.19, 172.82, 429.31, 176.21);
    path.cubicTo(429.34, 177.74, 429.34, 177.74, 429.38, 179.31);
    path.cubicTo(429.70, 187.86, 430.74, 196.72, 435.19, 204.19);
    path.cubicTo(437.93, 209.31, 437.84, 214.54, 437.00, 220.19);
    path.cubicTo(435.06, 225.99, 432.45, 231.07, 427.00, 234.19);
    path.cubicTo(420.87, 236.43, 415.17, 236.46, 408.69, 236.38);
    path.cubicTo(407.69, 236.37, 406.69, 236.37, 405.65, 236.37);
    path.cubicTo(398.28, 236.33, 398.28, 236.33, 396.00, 235.19);
    path.cubicTo(395.46, 232.89, 395.02, 230.57, 394.62, 228.25);
    path.cubicTo(392.07, 214.51, 386.92, 204.17, 375.38, 195.75);
    path.cubicTo(363.60, 188.00, 351.45, 185.53, 337.62, 188.38);
    path.cubicTo(324.68, 191.60, 314.38, 198.30, 307.28, 209.78);
    path.cubicTo(303.36, 217.15, 301.53, 224.62, 300.39, 232.85);
    path.cubicTo(300.00, 235.19, 300.00, 235.19, 299.00, 236.19);
    path.cubicTo(296.92, 236.28, 294.85, 236.31, 292.77, 236.31);
    path.cubicTo(291.78, 236.31, 291.78, 236.31, 290.77, 236.31);
    path.cubicTo(288.55, 236.31, 286.33, 236.31, 284.11, 236.30);
    path.cubicTo(282.52, 236.30, 280.93, 236.30, 279.35, 236.30);
    path.cubicTo(275.03, 236.30, 270.71, 236.30, 266.39, 236.29);
    path.cubicTo(261.88, 236.28, 257.37, 236.28, 252.86, 236.28);
    path.cubicTo(244.31, 236.28, 235.77, 236.27, 227.22, 236.26);
    path.cubicTo(217.50, 236.25, 207.77, 236.24, 198.04, 236.24);
    path.cubicTo(178.03, 236.23, 158.01, 236.21, 138.00, 236.19);
    path.cubicTo(137.89, 235.62, 137.79, 235.04, 137.68, 234.45);
    path.cubicTo(137.19, 231.83, 136.69, 229.21, 136.18, 226.59);
    path.cubicTo(135.93, 225.24, 135.93, 225.24, 135.68, 223.86);
    path.cubicTo(133.85, 214.46, 130.57, 206.49, 123.00, 200.19);
    path.cubicTo(122.43, 199.71, 121.85, 199.23, 121.26, 198.74);
    path.cubicTo(111.12, 190.67, 99.18, 185.70, 86.00, 187.19);
    path.cubicTo(72.17, 189.47, 60.73, 194.43, 52.02, 205.76);
    path.cubicTo(46.01, 214.72, 42.86, 223.48, 42.00, 234.19);
    path.cubicTo(38.94, 237.25, 30.17, 236.38, 26.12, 236.50);
    path.cubicTo(17.64, 236.44, 10.13, 234.32, 4.00, 228.19);
    path.cubicTo(-1.42, 220.44, -0.87, 211.28, 0.67, 202.25);
    path.cubicTo(1.19, 199.72, 1.76, 197.21, 2.34, 194.69);
    path.cubicTo(3.35, 189.34, 4.85, 185.47, 5.40, 180.77);
    path.cubicTo(7.29, 165.81, 9.15, 153.24, 21.57, 143.41);
    path.cubicTo(23.81, 141.69, 26.09, 140.04, 28.37, 138.39);
    path.cubicTo(36.11, 132.70, 43.21, 126.25, 50.24, 119.73);
    path.cubicTo(52.40, 117.74, 54.58, 115.79, 56.81, 113.88);
    path.cubicTo(61.55, 109.78, 66.08, 105.46, 70.63, 101.16);
    path.cubicTo(73.98, 98.01, 77.39, 95.04, 81.00, 92.19);
    path.cubicTo(81.89, 91.28, 82.77, 90.37, 83.69, 89.44);
    path.cubicTo(86.00, 87.19, 88.18, 85.00, 88.50, 84.69);
    path.cubicTo(89.00, 84.19, 89.00, 84.19, 89.00, 84.19);
    path.cubicTo(103.00, 69.77, 116.30, 67.01, 135.81, 65.99);
    path.close();
    path.moveTo(126.59, 86.48);
    path.cubicTo(110.28, 88.91, 97.89, 103.34, 86.87, 114.69);
    path.cubicTo(84.14, 117.96, 81.25, 120.85, 78.12, 123.75);
    path.cubicTo(74.46, 127.35, 74.46, 127.35, 72.75, 132.06);
    path.cubicTo(72.76, 135.06, 72.76, 135.06, 74.00, 136.84);
    path.cubicTo(77.16, 138.97, 80.55, 138.77, 84.25, 138.88);
    path.cubicTo(85.11, 138.91, 85.96, 138.94, 86.84, 138.97);
    path.cubicTo(95.18, 139.25, 103.53, 139.29, 111.88, 139.31);
    path.cubicTo(113.80, 139.32, 113.80, 139.32, 115.76, 139.33);
    path.cubicTo(122.06, 139.32, 128.34, 139.19, 134.63, 138.87);
    path.cubicTo(135.74, 138.81, 136.84, 138.75, 137.98, 138.69);
    path.cubicTo(142.03, 138.01, 144.81, 136.78, 147.30, 133.44);
    path.cubicTo(148.28, 130.28, 148.26, 127.42, 148.27, 124.11);
    path.cubicTo(148.27, 123.43, 148.27, 122.75, 148.27, 122.04);
    path.cubicTo(148.27, 120.60, 148.27, 119.15, 148.26, 117.71);
    path.cubicTo(148.25, 115.53, 148.26, 113.34, 148.27, 111.16);
    path.cubicTo(148.64, 98.81, 148.64, 98.81, 144.21, 87.65);
    path.cubicTo(139.10, 84.27, 132.41, 85.98, 126.59, 86.48);
    path.close();
    // Vector_3
    path.moveTo(255.36, 10.63);
    path.cubicTo(257.65, 12.35, 259.83, 14.14, 262.00, 16.00);
    path.cubicTo(262.60, 16.48, 263.19, 16.95, 263.80, 17.44);
    path.cubicTo(274.21, 26.61, 280.42, 41.49, 281.31, 55.06);
    path.cubicTo(282.26, 77.76, 269.76, 97.19, 258.67, 116.14);
    path.cubicTo(256.92, 119.14, 255.18, 122.14, 253.43, 125.14);
    path.cubicTo(247.04, 136.15, 240.60, 147.12, 234.00, 158.00);
    path.cubicTo(233.63, 158.61, 233.26, 159.22, 232.88, 159.85);
    path.cubicTo(231.78, 161.67, 230.67, 163.49, 229.56, 165.31);
    path.cubicTo(228.93, 166.36, 228.29, 167.41, 227.63, 168.49);
    path.cubicTo(225.14, 172.33, 223.00, 174.00, 219.00, 172.00);
    path.cubicTo(216.78, 169.40, 215.11, 166.50, 213.38, 163.56);
    path.cubicTo(212.85, 162.71, 212.33, 161.85, 211.79, 160.97);
    path.cubicTo(210.71, 159.18, 209.64, 157.40, 208.57, 155.61);
    path.cubicTo(207.13, 153.22, 205.67, 150.84, 204.20, 148.47);
    path.cubicTo(197.66, 137.95, 191.48, 127.23, 185.39, 116.44);
    path.cubicTo(184.12, 114.22, 182.84, 112.00, 181.56, 109.78);
    path.cubicTo(169.86, 89.52, 158.82, 69.49, 164.62, 45.44);
    path.cubicTo(169.92, 27.28, 181.38, 14.21, 197.88, 5.13);
    path.cubicTo(216.77, -3.64, 238.38, -1.08, 255.36, 10.63);
    path.close();
    path.moveTo(202.41, 38.57);
    path.cubicTo(195.83, 45.75, 194.35, 51.82, 194.59, 61.49);
    path.cubicTo(195.55, 69.76, 199.54, 75.46, 205.95, 80.60);
    path.cubicTo(212.16, 84.84, 218.52, 86.49, 226.00, 86.00);
    path.cubicTo(233.42, 84.43, 239.92, 81.04, 244.57, 74.94);
    path.cubicTo(249.58, 67.13, 250.03, 59.07, 249.00, 50.00);
    path.cubicTo(246.92, 43.01, 241.85, 38.13, 236.00, 34.00);
    path.cubicTo(224.59, 27.89, 211.78, 29.31, 202.41, 38.57);
    path.close();
    // Vector_4
    path.moveTo(369.57, 201.47);
    path.cubicTo(380.37, 209.22, 385.16, 219.99, 387.67, 232.60);
    path.cubicTo(389.07, 242.71, 383.83, 251.79, 377.95, 259.74);
    path.cubicTo(370.26, 268.63, 361.20, 272.37, 349.71, 273.85);
    path.cubicTo(341.86, 274.17, 333.68, 272.20, 327.00, 268.00);
    path.cubicTo(326.38, 267.61, 325.76, 267.23, 325.12, 266.83);
    path.cubicTo(317.76, 261.85, 311.89, 254.36, 309.44, 245.74);
    path.cubicTo(307.40, 232.96, 308.50, 221.99, 316.19, 211.31);
    path.cubicTo(329.56, 195.17, 351.08, 190.89, 369.57, 201.47);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 275.0;
    canvas.save();
    canvas.scale(scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(_cachedVanPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PassaiVanPainter oldDelegate) =>
      oldDelegate.color != color;
}
