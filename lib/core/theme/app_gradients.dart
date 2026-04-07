import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6), // purple-500
      Color(0xFFEC4899), // pink-500
      Color(0xFFF97316), // orange-500
    ],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA78BFA), // purple-400
      Color(0xFFF472B6), // pink-400
    ],
  );
}
