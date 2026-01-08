import 'package:flutter/material.dart';
import 'package:osox/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lightPrimary,
        primary: AppColors.lightPrimary,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        primary: AppColors.darkPrimary,
        brightness: Brightness.dark,
      ),
    );
  }
}
