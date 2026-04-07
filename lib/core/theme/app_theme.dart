import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _fallbackFonts = ['Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'];

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textMain,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w500, color: AppColors.textMain).copyWith(fontFamilyFallback: _fallbackFonts),
      displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textMain).copyWith(fontFamilyFallback: _fallbackFonts),
      displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textMain).copyWith(fontFamilyFallback: _fallbackFonts),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textMain).copyWith(fontFamilyFallback: _fallbackFonts),
      bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain).copyWith(fontFamilyFallback: _fallbackFonts),
      bodySmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary).copyWith(fontFamilyFallback: _fallbackFonts),
      labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain).copyWith(fontFamilyFallback: _fallbackFonts),
      labelMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMain).copyWith(fontFamilyFallback: _fallbackFonts),
      labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary).copyWith(fontFamilyFallback: _fallbackFonts),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textMain),
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textMain),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextMain,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w500, color: AppColors.darkTextMain).copyWith(fontFamilyFallback: _fallbackFonts),
      displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.darkTextMain).copyWith(fontFamilyFallback: _fallbackFonts),
      displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.darkTextMain).copyWith(fontFamilyFallback: _fallbackFonts),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.darkTextMain).copyWith(fontFamilyFallback: _fallbackFonts),
      bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkTextMain).copyWith(fontFamilyFallback: _fallbackFonts),
      bodySmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary).copyWith(fontFamilyFallback: _fallbackFonts),
      labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkTextMain).copyWith(fontFamilyFallback: _fallbackFonts),
      labelMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkTextMain).copyWith(fontFamilyFallback: _fallbackFonts),
      labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary).copyWith(fontFamilyFallback: _fallbackFonts),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkTextMain),
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.darkTextMain),
    ),
  );
}
