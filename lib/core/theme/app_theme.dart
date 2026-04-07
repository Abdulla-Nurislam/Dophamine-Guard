import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const emojiFallback = [
    'Apple Color Emoji', // iOS
    'Roboto',            // Android
    'Noto Color Emoji',  // Web/Linux
  ];

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
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: AppColors.textMain,
      displayColor: AppColors.textMain,
      fontFamilyFallback: emojiFallback,
    ),
    primaryTextTheme: GoogleFonts.montserratTextTheme(ThemeData.light().primaryTextTheme).apply(
      bodyColor: AppColors.textMain,
      displayColor: AppColors.textMain,
      fontFamilyFallback: emojiFallback,
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
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.darkTextMain,
      displayColor: AppColors.darkTextMain,
      fontFamilyFallback: emojiFallback,
    ),
    primaryTextTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().primaryTextTheme).apply(
      bodyColor: AppColors.darkTextMain,
      displayColor: AppColors.darkTextMain,
      fontFamilyFallback: emojiFallback,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkTextMain),
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.darkTextMain),
    ),
  );
}
