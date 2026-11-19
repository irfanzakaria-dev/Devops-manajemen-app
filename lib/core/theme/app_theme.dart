import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors matching UI/UX in Untitled (3)
  static const Color primaryMint = Color(0xFF00D2A0);
  static const Color primaryMintDark = Color(0xFF00A880);
  static const Color bgDark = Color(0xFF0A0E17);
  static const Color bgSurface = Color(0xFF131926);
  static const Color bgSurfaceElevated = Color(0xFF1B2334);
  static const Color borderSubtle = Color(0xFF222C3E);
  static const Color borderFocused = Color(0xFF3B4860);
  
  // Status & Severity Colors
  static const Color sev1Critical = Color(0xFFFF4D4F);
  static const Color sev2Warning = Color(0xFFFAAD14);
  static const Color sev3Info = Color(0xFF1890FF);
  static const Color statusSuccess = Color(0xFF00D2A0);
  
  // Role Badges
  static const Color roleLead = Color(0xFF8B5CF6);
  static const Color roleDeveloper = Color(0xFF06B6D4);
  static const Color roleQA = Color(0xFF10B981);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF57606A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryMint,
      canvasColor: bgDark,
      cardColor: bgSurface,
      dividerColor: borderSubtle,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryMint,
        secondary: roleDeveloper,
        surface: bgSurface,
        error: sev1Critical,
        onPrimary: Color(0xFF0A0E17),
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }
}
