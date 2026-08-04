import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF7C6CFF);
  static const success = Color(0xFF3DD68C);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFFF5C5C);
  static const darkBg = Color(0xFF0E1116);
  static const darkSurface = Color(0xFF161B22);
}

class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    return base.copyWith(
      textTheme: GoogleFonts.beVietnamProTextTheme(base.textTheme),
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? AppColors.darkBg : null,
      appBarTheme: AppBarTheme(
        backgroundColor:
            brightness == Brightness.dark ? AppColors.darkBg : scheme.surface,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? AppColors.darkSurface
            : scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.darkSurface
            : scheme.surface,
      ),
    );
  }
}