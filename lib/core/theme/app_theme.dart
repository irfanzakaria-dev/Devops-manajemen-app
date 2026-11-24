import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors matching UI/UX
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

  // Dark Text Colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF57606A);

  // Light Theme Colors
  static const Color bgLight = Color(0xFFF1F5F9);
  static const Color bgLightSurface = Color(0xFFFFFFFF);
  static const Color bgLightSurfaceElevated = Color(0xFFE2E8F0);
  static const Color borderLightSubtle = Color(0xFFCBD5E1);
  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF64748B);
  static const Color textLightMuted = Color(0xFF94A3B8);

  // Dynamic Context-Aware Colors (Responsive to Dark / Light Mode)
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? bgDark : bgLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? bgSurface : bgLightSurface;

  static Color surfaceElevated(BuildContext context) =>
      isDark(context) ? bgSurfaceElevated : bgLightSurfaceElevated;

  static Color border(BuildContext context) =>
      isDark(context) ? borderSubtle : borderLightSubtle;

  static Color text(BuildContext context) =>
      isDark(context) ? textPrimary : textLightPrimary;

  static Color textSubtle(BuildContext context) =>
      isDark(context) ? textSecondary : textLightSecondary;

  static Color textMutedColor(BuildContext context) =>
      isDark(context) ? textMuted : textLightMuted;

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

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primaryMint,
      canvasColor: bgLight,
      cardColor: bgLightSurface,
      dividerColor: borderLightSubtle,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textLightPrimary),
        bodyMedium: TextStyle(color: textLightPrimary),
        bodySmall: TextStyle(color: textLightSecondary),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryMint,
        secondary: roleDeveloper,
        surface: bgLightSurface,
        error: sev1Critical,
        onPrimary: Color(0xFFFFFFFF),
        onSurface: textLightPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textLightPrimary,
        ),
        iconTheme: const IconThemeData(color: textLightPrimary),
      ),
    );
  }
}
