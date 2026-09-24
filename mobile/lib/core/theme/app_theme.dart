import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Tema central do Passaí — aplicado via MaterialApp.theme
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    // Aplica Manrope em TODOS os roles do Material3 para evitar fetch externo de Roboto.
    final baseTextTheme = const TextTheme().apply(
      fontFamily: 'Manrope',
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // Merge: roles explícitos do Passaí + todos os demais em Manrope
      textTheme: baseTextTheme.merge(TextTheme(
        displayLarge: AppTextStyles.headingXL(),
        titleLarge: AppTextStyles.headingLG(),
        titleMedium: AppTextStyles.headingMD(),
        bodyMedium: AppTextStyles.bodyRegular(),
      )),
      typography: Typography.material2021(
        platform: TargetPlatform.android,
        black: Typography.blackMountainView.apply(fontFamily: 'Manrope'),
        white: Typography.whiteMountainView.apply(fontFamily: 'Manrope'),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
