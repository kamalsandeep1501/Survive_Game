import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0A1A);
  
  // Blue Zone (Player Base)
  static const Color bluePrimary = Color(0xFF1565C0);
  static const Color blueLight = Color(0xFF4FC3F7);
  static const Color blueDark = Color(0xFF0D47A1);

  // Red Creep (Enemy)
  static const Color redPrimary = Color(0xFFC62828);
  static const Color redLight = Color(0xFFEF9A9A);
  static const Color redDark = Color(0xFFB71C1C);

  static const Color gold = Color(0xFFFFD700);

  static const TextStyle titleStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  static const TextStyle scoreStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
