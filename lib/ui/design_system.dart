import 'package:flutter/material.dart';

class BabyColors {
  static const Color primary = Color(0xFF7EC8E3);
  static const Color secondary = Color(0xFFF7C9D1);
  static const Color tertiary = Color(0xFFFFEAA7);
  static const Color background = Colors.white;
  static const Color pastelSection = Color(0xFFFDF7F9);
}

class BabySpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class BabyRadii {
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(30));
}

class BabyShadows {
  static List<BoxShadow> soft = [
    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
  ];
}

ThemeData babyTheme = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: BabyColors.primary,
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: const ColorScheme.light(
    primary: BabyColors.primary,
    secondary: BabyColors.secondary,
    tertiary: BabyColors.tertiary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: BabyColors.secondary,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: BabyColors.secondary,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
    elevation: 4,
  ),
  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: BabyColors.secondary),
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BabyColors.secondary,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: BabyColors.secondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.grey[700],
      side: BorderSide(color: Colors.grey[300]!),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  ),
);
