import 'package:flutter/material.dart';

class DesignTokens {
  // Primary colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentBlue = Color(0xFFE3F2FD);
  
  // Background colors
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color darkBg = Color(0xFF1A1C1E);
  
  // Neumorphic Shadows - Light
  static const List<BoxShadow> neumorphicShadowLight = [
    BoxShadow(
      color: Colors.white,
      offset: Offset(-4, -4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Color(0x33AEB5BC), // 20% opacity of Color(0xFFAEB5BC)
      offset: Offset(4, 4),
      blurRadius: 10,
    ),
  ];
  
  // Neumorphic Shadows - Dark
  static const List<BoxShadow> neumorphicShadowDark = [
    BoxShadow(
      color: Color(0x0DFFFFFF), // 5% opacity of white
      offset: Offset(-4, -4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Color(0x80000000), // 50% opacity of black
      offset: Offset(4, 4),
      blurRadius: 10,
    ),
  ];
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
}
