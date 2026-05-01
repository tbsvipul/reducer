import 'package:flutter/material.dart';

/// Centralized color palette for Reducer
/// All screens reference this file — never hardcode colors in screens.
class AppColors {
  AppColors._();

  // ── Brand Core ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF5C6BC0); // Indigo 400
  static const Color primaryLight = Color(0xFF9FA8DA); // Indigo 200
  static const Color primaryDark = Color(0xFF3949AB); // Indigo 600
  static const Color primaryContainer = Color(0xFFE8EAF6); // Indigo 50

  static const Color secondary = Color(0xFF26C6DA); // Cyan 400
  static const Color secondaryLight = Color(0xFF80DEEA);
  static const Color secondaryDark = Color(0xFF0097A7);
  static const Color secondaryContainer = Color(0xFFE0F7FA);

  static const Color premium = Color(0xFFF59E0B); // Amber 500 — for crown/pro
  static const Color premiumLight = Color(0xFFFDE68A);
  static const Color premiumContainer = Color(0xFFFFFBEB);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFFFBEB);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F2F8);
  static const Color lightBorder = Color(0xFFE4E7F0);
  static const Color lightDivider = Color(0xFFEEF0F8);

  // ── Dark Theme Surfaces ──────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1117); // Near-black
  static const Color darkSurface = Color(0xFF1A1D27); // Card bg
  static const Color darkSurfaceVariant = Color(0xFF242736); // Elevated card
  static const Color darkBorder = Color(0xFF2E3246);
  static const Color darkDivider = Color(0xFF252840);

  // ── On-Colors ─────────────────────────────────────────────────────────────────
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onPremium = Colors.white;

  static const Color onLightBackground = Color(0xFF1A1D27);
  static const Color onLightSurface = Color(0xFF1A1D27);
  static const Color onLightSurfaceVariant = Color(0xFF6B7280);

  static const Color onDarkBackground = Color(0xFFF1F3FA);
  static const Color onDarkSurface = Color(0xFFF1F3FA);
  static const Color onDarkSurfaceVariant = Color(0xFF9CA3AF);

  // ── Gradients ─────────────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [primary, Color(0xFF7986CB)];
  static const List<Color> premiumGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFC6736),
  ];
  static const List<Color> splashGradient = [
    Color(0xFF0F172A),
    Color(0xFF020617),
  ];
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> darkSurfaceGradient = [
    Color(0xFF1E293B),
    Color(0xFF0F172A),
  ];
  static const List<Color> lightSurfaceGradient = [
    Color(0xFFF8FAFC),
    Color(0xFFF1F5F9),
  ];

  // ── Shadows ───────────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: const Color(0xFF5C6BC0).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> premiumButtonShadow = [
    BoxShadow(
      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
