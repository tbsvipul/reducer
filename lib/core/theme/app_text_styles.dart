import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography accessors backed by the active [TextTheme].
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _style(
    BuildContext context,
    TextStyle? base, {
    FontWeight weight = FontWeight.w400,
    double? height,
    double letterSpacing = 0,
    Color? color,
  }) {
    final fallback = GoogleFonts.inter();
    return (base ?? fallback).copyWith(
      fontFamily: fallback.fontFamily,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextTheme _theme(BuildContext context) => Theme.of(context).textTheme;

  static TextStyle displayLarge(BuildContext context) => _style(
    context,
    _theme(context).displayLarge,
    weight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.12,
  );

  static TextStyle displayMedium(BuildContext context) => _style(
    context,
    _theme(context).displayMedium,
    weight: FontWeight.w700,
    letterSpacing: -1,
    height: 1.15,
  );

  static TextStyle displaySmall(BuildContext context) => _style(
    context,
    _theme(context).displaySmall,
    weight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle headlineLarge(BuildContext context) => _style(
    context,
    _theme(context).headlineLarge,
    weight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static TextStyle headlineMedium(BuildContext context) => _style(
    context,
    _theme(context).headlineMedium,
    weight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.28,
  );

  static TextStyle headlineSmall(BuildContext context) => _style(
    context,
    _theme(context).headlineSmall,
    weight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle titleLarge(BuildContext context) => _style(
    context,
    _theme(context).titleLarge,
    weight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle titleMedium(BuildContext context) => _style(
    context,
    _theme(context).titleMedium,
    weight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle titleSmall(BuildContext context) => _style(
    context,
    _theme(context).titleSmall,
    weight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle bodyLarge(BuildContext context) => _style(
    context,
    _theme(context).bodyLarge,
    weight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium(BuildContext context) => _style(
    context,
    _theme(context).bodyMedium,
    weight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall(BuildContext context) => _style(
    context,
    _theme(context).bodySmall,
    weight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle labelLarge(BuildContext context) => _style(
    context,
    _theme(context).labelLarge,
    weight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium(BuildContext context) => _style(
    context,
    _theme(context).labelMedium,
    weight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall(BuildContext context) => _style(
    context,
    _theme(context).labelSmall,
    weight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle statValue(BuildContext context) => _style(
    context,
    _theme(context).headlineSmall,
    weight: FontWeight.w800,
    height: 1.1,
  );

  static TextStyle statLabel(BuildContext context) => _style(
    context,
    _theme(context).labelSmall,
    weight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle buttonText(BuildContext context) => _style(
    context,
    _theme(context).labelLarge,
    weight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static TextStyle tabLabel(BuildContext context) => _style(
    context,
    _theme(context).labelMedium,
    weight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle chipLabel(BuildContext context) =>
      _style(context, _theme(context).labelMedium, weight: FontWeight.w500);

  static TextStyle badgeLabel(BuildContext context) => _style(
    context,
    _theme(context).labelSmall,
    weight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
