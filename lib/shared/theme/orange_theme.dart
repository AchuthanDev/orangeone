import 'package:flutter/material.dart';

abstract final class OrangeTheme {
  static const brand = Color(0xFFFF6A00);
  static const dark = Color(0xFFBE4602);
  static const camera = Color(0xFF1B120B);
  static const pale = Color(0xFFFFF3E8);
  static const secondary = Color(0xFF5F6368);
  static const scannerAccent = Color(0xFFF56600);
  static const homeGradient = LinearGradient(
    begin: Alignment(-1, -.3),
    end: Alignment(1, .3),
    colors: [dark, brand],
  );
  static const scannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dark, Color(0xB0FF6A00)],
  );
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB63F00), brand],
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(seedColor: brand),
  );
}
