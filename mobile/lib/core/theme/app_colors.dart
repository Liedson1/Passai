import 'package:flutter/material.dart';

/// Paleta de cores do Passaí baseada nos design tokens
class AppColors {
  AppColors._();

  // Cores primárias
  static const Color primary = Color(0xFFD95438);
  static const Color primaryDark = Color(0xFFB33D24);
  static const Color primaryLight = Color(0xFFFCECE8);

  // Cores secundárias
  static const Color secondary = Color(0xFF0A5C66);
  static const Color secondaryLight = Color(0xFFE6F3F5);

  // Superfícies e fundo
  static const Color background = Color(0xFFF9F6F0);     // fundo geral da tela
  static const Color inputBackground = Color(0xFFF0EAE1); // fundo dos inputs
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEADFD5);

  // Texto
  static const Color textPrimary = Color(0xFF2B1D19);
  static const Color textSecondary = Color(0xFF8F7D77);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Overlay do hero
  static const Color heroOverlay = Color(0x26FFFFFF); // rgba(255,255,255,0.15)
  static const Color heroSubtitle = Color(0xD9F9F6F0); // rgba(249,246,240,0.85)

  // Status pills — tela de resultados
  static const Color success = Color(0xFF2D8A4E);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE67E22);
  static const Color warningLight = Color(0xFFFFF3E0);

  // Amber — usado no card de benefício "Sem Surpresas"
  static const Color amber = Color(0xFFB45309);
  static const Color amberLight = Color(0xFFFEF3C7);

  // Seletor de data
  static const Color dateChipActive = primary;
  static const Color dateChipInactive = Color(0xFFF5F0E8);

  // Versão Web — Destaques e Rodapé
  static const Color titleGold = Color(0xFFFFD166);
  static const Color footerBackground = Color(0xFF231B18);
  static const Color footerText = Color(0xFFA09690);
}

