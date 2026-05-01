// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

/// Legacy compatibility shim — all screens that still import DesignTokens
/// will automatically use the new palette. Prefer AppColors in new code.
class DesignTokens {
  // ── Primary (mapped to new palette) ─────────────────────────────────────────
  static const Color primaryBlue = AppColors.primary;
  static const Color accentBlue = AppColors.primaryContainer;
  static const Color googleBlue = AppColors.primary;
  static const Color googleRed = AppColors.error;
  static const Color googleYellow = AppColors.premium;
  static const Color googleGreen = AppColors.success;

  // ── Backgrounds ───────────────────────────────────────────────────────────────
  static const Color lightBg = AppColors.lightBackground;
  static const Color darkBg = AppColors.darkBackground;

  // ── Dark neumorphic replaced by clean card shadows ────────────────────────────
  static List<BoxShadow> get neumorphicShadowLight => AppColors.cardShadowLight;
  static List<BoxShadow> get neumorphicShadowDark => AppColors.cardShadowDark;

  // ── Border Radius ─────────────────────────────────────────────────────────────
  static double get radiusSmall => AppDimensions.radiusSm;
  static double get radiusMedium => AppDimensions.radiusLg;
  static double get radiusLarge => AppDimensions.radiusXl2;
}
