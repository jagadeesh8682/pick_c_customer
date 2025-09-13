import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F7F9),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(250, 250, 253, 1),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      foregroundColor: Colors.black,
    ),

    cardColor: Colors.white,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromRGBO(250, 250, 253, 1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.2),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );

  static ThemeData getTheme({Brightness brightness = Brightness.light}) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }
}
