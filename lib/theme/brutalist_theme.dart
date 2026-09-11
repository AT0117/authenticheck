import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrutalistTheme {
  static const Color neonGreen = Color(0xFF00FF41);
  static const Color neonRed = Color(0xFFFF003C);
  static const Color black = Color(0xFF0D0D0D);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFE0E0E0);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonRed,
        surface: darkGray,
        onSurface: textLight,
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.inter(color: textLight),
        bodyMedium: GoogleFonts.inter(color: textLight),
        displayLarge: GoogleFonts.robotoMono(
          color: neonGreen,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.robotoMono(
          color: textLight,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.robotoMono(
          color: neonGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: const CardThemeData(
        color: darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: textLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: GoogleFonts.robotoMono(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGray,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: textLight),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: textLight),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: neonGreen, width: 2),
        ),
        labelStyle: GoogleFonts.robotoMono(color: textLight),
      ),
    );
  }
}
