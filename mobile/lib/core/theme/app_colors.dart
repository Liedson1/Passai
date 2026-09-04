import 'package:flutter/material.dart';

/// Paleta de cores do Passaí baseada nos design tokens
class AppColors {
  AppColors._();

  // Cores primárias
  static const Color primary = Color(0xFFD95438);
  static const Color primaryLight = Color(0xFFFCECE8);

  // Cores secundárias
  static const Color secondary = Color(0xFF0A5C66);
  static const Color secondaryLight = Color(0xFFE6F3F5);

  // Superfícies e fundo
  static const Color background = Color(0xFFF0EAE1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEADFD5);

  // Texto
  static const Color textPrimary = Color(0xFF2B1D19);
  static const Color textSecondary = Color(0xFF8F7D77);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Overlay do hero
  static const Color heroOverlay = Color(0x26FFFFFF); // rgba(255,255,255,0.15)
  static const Color heroSubtitle = Color(0xD9F9F6F0); // rgba(249,246,240,0.85)
}
