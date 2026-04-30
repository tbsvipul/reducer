import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static final String? _fontFamily = GoogleFonts.inter().fontFamily;

  // ─────────────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.premium,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.premiumContainer,
      onTertiaryContainer: Color(0xFFB45309),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: Color(0xFF991B1B),
      surface: AppColors.lightBackground,
      onSurface: AppColors.onLightBackground,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.onLightSurfaceVariant,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightDivider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.onDarkSurface,
      inversePrimary: AppColors.primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(colorScheme),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.onLightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onLightBackground,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.onLightBackground, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.primary, size: 22),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
          textStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(fontFamily: _fontFamily, color: AppColors.onLightSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(fontFamily: _fontFamily, color: AppColors.onLightSurfaceVariant, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onLightSurfaceVariant,
        indicator: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primary, width: 2.5)),
        ),
        labelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.lightBorder,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.primaryDark,
      primaryContainer: Color(0xFF2A2E4A),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.secondaryDark,
      secondaryContainer: Color(0xFF1A2E30),
      onSecondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.premiumLight,
      onTertiary: Color(0xFF78350F),
      tertiaryContainer: Color(0xFF2A2010),
      onTertiaryContainer: AppColors.premiumLight,
      error: Color(0xFFF87171),
      onError: Color(0xFF7F1D1D),
      errorContainer: Color(0xFF3A1414),
      onErrorContainer: Color(0xFFF87171),
      surface: AppColors.darkBackground,
      onSurface: AppColors.onDarkBackground,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.onDarkSurfaceVariant,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.onLightSurface,
      inversePrimary: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(colorScheme),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.onDarkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onDarkBackground,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.onDarkBackground, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.primaryLight, size: 22),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(fontFamily: _fontFamily, color: AppColors.onDarkSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(fontFamily: _fontFamily, color: AppColors.onDarkSurfaceVariant, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.onDarkSurfaceVariant,
        indicator: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 2.5)),
        ),
        labelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.darkBorder,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SHARED TEXT THEME (Optimized for Local Bundling)
  // ─────────────────────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(ColorScheme cs) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, color: cs.onSurface, fontFamily: _fontFamily),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, color: cs.onSurface, fontFamily: _fontFamily),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: cs.onSurface, fontFamily: _fontFamily),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface, fontFamily: _fontFamily),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface, fontFamily: _fontFamily),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: _fontFamily),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: _fontFamily),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: _fontFamily),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: _fontFamily),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: cs.onSurface, fontFamily: _fontFamily),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: cs.onSurface, fontFamily: _fontFamily),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cs.onSurfaceVariant, fontFamily: _fontFamily),
    );
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1),
    );
  }

  static BoxDecoration primaryGradientDecoration({double? radius}) {
    return BoxDecoration(
      gradient: const LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(radius ?? AppDimensions.radiusLg),
    );
  }
}

