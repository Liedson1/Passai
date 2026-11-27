import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos tipográficos do Passaí (Outfit + Manrope)
/// Fontes empacotadas localmente como assets para zero FOUT e carregamento instantâneo.
class AppTextStyles {
  AppTextStyles._();

  // Outfit — headings
  static TextStyle headingXL({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontFamily: 'Outfit',
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle headingLG({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontFamily: 'Outfit',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle headingMD({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // Manrope — corpo
  static TextStyle bodyRegular({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
  }) =>
      TextStyle(
        fontFamily: 'Manrope',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodyMedium({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
  }) =>
      TextStyle(
        fontFamily: 'Manrope',
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodySemibold({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
  }) =>
      TextStyle(
        fontFamily: 'Manrope',
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyBold({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
  }) =>
      TextStyle(
        fontFamily: 'Manrope',
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
