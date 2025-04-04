import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getThemeData() {
    return ThemeData(
        brightness: Brightness.light,
        textTheme: TextTheme(
          headlineMedium: AppTextStyles.headlineMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineSmall: AppTextStyles.headlineSmall,
          bodyMedium: AppTextStyles.bodyMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodySmall: AppTextStyles.bodySmall,
        ),
        colorScheme: ColorScheme(
          primary: AppColors.primary,
          onPrimary: AppColors.background,
          secondary: AppColors.secondary,
          onSecondary: AppColors.background,
          error: AppColors.errorColor,
          onError: AppColors.surface,
          surface: AppColors.background,
          onSurface: AppColors.textColor,
          brightness: Brightness.light,
        ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor:AppColors.background,
          elevation: 0,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
        )
      )
    );
  }
}
