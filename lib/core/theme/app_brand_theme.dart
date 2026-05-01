import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppBrandTheme extends ThemeExtension<AppBrandTheme> {
  const AppBrandTheme({
    required this.primaryGradient,
    required this.premiumGradient,
    required this.heroBackgroundGradient,
    required this.cardShadow,
    required this.buttonShadow,
    required this.premiumButtonShadow,
    required this.heroBackground,
    required this.heroForeground,
    required this.mutedForeground,
  });

  final Gradient primaryGradient;
  final Gradient premiumGradient;
  final Gradient heroBackgroundGradient;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> buttonShadow;
  final List<BoxShadow> premiumButtonShadow;
  final Color heroBackground;
  final Color heroForeground;
  final Color mutedForeground;

  factory AppBrandTheme.light(ColorScheme colorScheme) {
    return AppBrandTheme(
      primaryGradient: const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      premiumGradient: const LinearGradient(
        colors: AppColors.premiumGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      heroBackgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8F3FF), Color(0xFFF8FBFF), Color(0xFFE0EFFF)],
      ),
      cardShadow: AppColors.cardShadowLight,
      buttonShadow: AppColors.buttonShadow,
      premiumButtonShadow: AppColors.premiumButtonShadow,
      heroBackground: const Color(0xFFF1F7FF),
      heroForeground: colorScheme.onSurface,
      mutedForeground: colorScheme.onSurfaceVariant,
    );
  }

  factory AppBrandTheme.dark(ColorScheme colorScheme) {
    return AppBrandTheme(
      primaryGradient: const LinearGradient(
        colors: [Color(0xFF7C8BDA), Color(0xFF5C6BC0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      premiumGradient: const LinearGradient(
        colors: [Color(0xFFFAC54F), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      heroBackgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF111827), Color(0xFF0B1220), Color(0xFF111F38)],
      ),
      cardShadow: AppColors.cardShadowDark,
      buttonShadow: AppColors.buttonShadow,
      premiumButtonShadow: AppColors.premiumButtonShadow,
      heroBackground: const Color(0xFF0B1220),
      heroForeground: colorScheme.onSurface,
      mutedForeground: colorScheme.onSurfaceVariant,
    );
  }

  @override
  AppBrandTheme copyWith({
    Gradient? primaryGradient,
    Gradient? premiumGradient,
    Gradient? heroBackgroundGradient,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? buttonShadow,
    List<BoxShadow>? premiumButtonShadow,
    Color? heroBackground,
    Color? heroForeground,
    Color? mutedForeground,
  }) {
    return AppBrandTheme(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      premiumGradient: premiumGradient ?? this.premiumGradient,
      heroBackgroundGradient:
          heroBackgroundGradient ?? this.heroBackgroundGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      premiumButtonShadow: premiumButtonShadow ?? this.premiumButtonShadow,
      heroBackground: heroBackground ?? this.heroBackground,
      heroForeground: heroForeground ?? this.heroForeground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
    );
  }

  @override
  AppBrandTheme lerp(ThemeExtension<AppBrandTheme>? other, double t) {
    if (other is! AppBrandTheme) {
      return this;
    }

    return AppBrandTheme(
      primaryGradient: Gradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      premiumGradient: Gradient.lerp(
        premiumGradient,
        other.premiumGradient,
        t,
      )!,
      heroBackgroundGradient: Gradient.lerp(
        heroBackgroundGradient,
        other.heroBackgroundGradient,
        t,
      )!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      buttonShadow: t < 0.5 ? buttonShadow : other.buttonShadow,
      premiumButtonShadow: t < 0.5
          ? premiumButtonShadow
          : other.premiumButtonShadow,
      heroBackground: Color.lerp(heroBackground, other.heroBackground, t)!,
      heroForeground: Color.lerp(heroForeground, other.heroForeground, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
    );
  }
}

extension AppBrandThemeContext on BuildContext {
  AppBrandTheme get brandTheme => Theme.of(this).extension<AppBrandTheme>()!;
}
