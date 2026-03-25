import 'package:flutter/material.dart';

class AppColors {
  // Global theme flag
  static bool isWorkerTheme = false;

  // Dynamic primary color based on theme
  static Color get primaryColor => isWorkerTheme ? successGreen : primaryBlue;

  static const Color primary = Color(0xFF3D7AB5);
  static const Color primaryBlue = Color(0xFF3D7AB5);
  static const Color darkBlue = Color(0xFF2C5F8A);
  static const Color lightBlue = Color(0xFFC8DFF0);
  static const Color paleBlue = Color(0xFFEEF5FB);
  static const Color text = Color(0xFF1A2533);
  static const Color muted = Color(0xFF7A8FA3);
  static const Color border = Color(0xFFDDE9FB);
  static const Color successGreen = Color(0xFF1A8C4E);
  static const Color greenBG = Color(0xFFE6F7EE);
  static const Color orangeWarning = Color(0xFFE07B39);
  static const Color orangeBG = Color(0xFFFDF0E8);
  static const Color background = Color(0xFFF6F9FC);
  static const Color white = Color(0xFFFFFFFF);

  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, isWorkerTheme ? successGreen.withOpacity(0.8) : darkBlue],
  );

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.12),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];
}
