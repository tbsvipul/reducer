import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryBlue,
        background: DesignTokens.lightBg,
      ),
      scaffoldBackgroundColor: DesignTokens.lightBg,
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryBlue,
        background: DesignTokens.darkBg,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: DesignTokens.darkBg,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Cached decorations to avoid recreating on every call
  static BoxDecoration? _cachedLightDecoration;
  static BoxDecoration? _cachedDarkDecoration;
  
  static BoxDecoration neumorphicDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      return _cachedDarkDecoration ??= BoxDecoration(
        color: DesignTokens.darkBg,
        borderRadius: const BorderRadius.all(Radius.circular(DesignTokens.radiusMedium)),
        boxShadow: DesignTokens.neumorphicShadowDark,
      );
    } else {
      return _cachedLightDecoration ??= BoxDecoration(
        color: DesignTokens.lightBg,
        borderRadius: const BorderRadius.all(Radius.circular(DesignTokens.radiusMedium)),
        boxShadow: DesignTokens.neumorphicShadowLight,
      );
    }
  }
}
