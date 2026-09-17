import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _darkBg = Color(0xFF050510);
  static const _darkSurface = Color(0xFF0D1117);
  static const _darkCard = Color(0xFF0D1117);
  static const _darkBorder = Color(0xFF1C2128);

  static const _lightBg = Color(0xFFF5F6FA);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightCard = Color(0xFFFFFFFF);
  static const _lightBorder = Color(0xFFE1E4E8);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyan,
          secondary: Colors.orange,
          surface: _darkSurface,
          onSurface: Colors.white,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
        ),
        scaffoldBackgroundColor: _darkBg,
        cardTheme: const CardThemeData(
          color: _darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _darkSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        dividerColor: _darkBorder,
        chipTheme: ChipThemeData(
          backgroundColor: _darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: const BorderSide(color: _darkBorder),
          labelStyle: const TextStyle(fontSize: 11),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 15),
          bodyMedium: TextStyle(fontSize: 13),
          bodySmall: TextStyle(fontSize: 12),
          labelLarge: TextStyle(fontSize: 14),
          labelMedium: TextStyle(fontSize: 13),
          labelSmall: TextStyle(fontSize: 11),
          titleLarge: TextStyle(fontSize: 18),
          titleMedium: TextStyle(fontSize: 16),
          titleSmall: TextStyle(fontSize: 14),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0097A7),
          secondary: Color(0xFFE65100),
          surface: _lightSurface,
          onSurface: Color(0xFF1F2328),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          outline: _lightBorder,
        ),
        scaffoldBackgroundColor: _lightBg,
        cardTheme: const CardThemeData(
          color: _lightCard,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _lightSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        dividerColor: _lightBorder,
        chipTheme: ChipThemeData(
          backgroundColor: _lightBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: const BorderSide(color: _lightBorder),
          labelStyle: const TextStyle(fontSize: 11),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 15),
          bodyMedium: TextStyle(fontSize: 13),
          bodySmall: TextStyle(fontSize: 12),
          labelLarge: TextStyle(fontSize: 14),
          labelMedium: TextStyle(fontSize: 13),
          labelSmall: TextStyle(fontSize: 11),
          titleLarge: TextStyle(fontSize: 18),
          titleMedium: TextStyle(fontSize: 16),
          titleSmall: TextStyle(fontSize: 14),
        ),
      );
}
