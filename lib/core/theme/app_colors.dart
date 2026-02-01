import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Modern Health Tech Palette
  static const Color primary = Color(
    0xFF4F46E5,
  ); // Indigo 600 - Trustworthy, Modern
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400

  static const Color secondary = Color(
    0xFF10B981,
  ); // Emerald 500 - Health, Success
  static const Color secondaryDark = Color(0xFF047857);
  static const Color secondaryLight = Color(0xFF6EE7B7);

  static const Color accent = Color(0xFFF59E0B); // Amber 500 - Warmth, Warning
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color success = Color(0xFF10B981); // Same as secondary

  // Neutrals - Slate Scale for crisp text
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textMedium = Color(0xFF334155); // Slate 700
  static const Color textLight = Color(0xFF64748B); // Slate 500
  static const Color disabled = Color(0xFFCBD5E1); // Slate 300

  // Backgrounds
  static const Color background = Color(
    0xFFF8FAFC,
  ); // Slate 50 - Very soft cool white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardStroke = Color(0xFFE2E8F0); // Slate 200

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF8B5CF6)], // Indigo to Violet
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient healthGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF3B82F6)], // Emerald to Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white24, Colors.white10],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
