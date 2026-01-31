import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color iconBackground = Color(0xFFEFF6FF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textTertiary,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  static TextStyle get labelText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.3,
      );
}
