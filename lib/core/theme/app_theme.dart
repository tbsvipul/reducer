import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

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

      // ── AppBar ───────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.onLightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onLightBackground,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.onLightBackground, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.primary, size: 22),
      ),

      // ── Cards ─────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),

      // ── Elevated Buttons ──────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Outlined Buttons ──────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Text Buttons ──────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Filled Buttons ────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Icon Buttons ──────────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onLightSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.onLightSurfaceVariant, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.onLightSurfaceVariant, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Slider ────────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryContainer,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.15),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      // ── Switch ────────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? Colors.white : AppColors.onLightSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primary : AppColors.lightSurfaceVariant;
        }),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        side: const BorderSide(color: AppColors.lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Tabs ──────────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onLightSurfaceVariant,
        indicator: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primary, width: 2.5)),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.lightBorder,
      ),

      // ── Divider ───────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 0,
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl2)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.lightBorder,
        elevation: 0,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onLightSurface,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onLightSurfaceVariant,
          height: 1.5,
        ),
      ),

      // ── Snackbar ─────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: GoogleFonts.inter(color: AppColors.onDarkSurface, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ── Progress Indicator ────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),

      // ── List Tile ─────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        titleTextStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.onLightSurface),
        subtitleTextStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.onLightSurfaceVariant),
      ),

      // ── Navigation Bar ────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.onLightSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.onLightSurfaceVariant,
            size: 22,
          );
        }),
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
        titleTextStyle: GoogleFonts.inter(
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.onDarkSurfaceVariant, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.onDarkSurfaceVariant, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: const Color(0xFF2A2E4A),
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.15),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.darkBackground : AppColors.onDarkSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.primaryLight : AppColors.darkSurfaceVariant;
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: const Color(0xFF2A2E4A),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onDarkSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        side: const BorderSide(color: AppColors.darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.onDarkSurfaceVariant,
        indicator: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 2.5)),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.darkBorder,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 0,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl2)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.darkBorder,
        elevation: 0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onDarkSurface),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onDarkSurfaceVariant, height: 1.5),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: GoogleFonts.inter(color: AppColors.onDarkSurface, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: Color(0xFF2A2E4A),
        circularTrackColor: Color(0xFF2A2E4A),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        titleTextStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.onDarkSurface),
        subtitleTextStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.onDarkSurfaceVariant),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: const Color(0xFF2A2E4A),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primaryLight : AppColors.onDarkSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primaryLight : AppColors.onDarkSurfaceVariant,
            size: 22,
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SHARED TEXT THEME
  // ─────────────────────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(ColorScheme cs) {
    return GoogleFonts.interTextTheme(TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -1.5, color: cs.onSurface),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: -1, color: cs.onSurface),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: cs.onSurface),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: cs.onSurface),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: cs.onSurface),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: cs.onSurface),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: cs.onSurface),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: cs.onSurface),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: cs.onSurface),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: cs.onSurfaceVariant),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: cs.onSurface),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: cs.onSurfaceVariant),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: cs.onSurfaceVariant),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SHARED DECORATION HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Modern card decoration that adapts to light/dark
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      ),
      boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
    );
  }

  /// Elevated card (more prominent shadow)
  static BoxDecoration elevatedCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      ),
      boxShadow: isDark
          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 32, offset: const Offset(0, 12))]
          : [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 32, offset: const Offset(0, 12)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
    );
  }

  /// Primary gradient button decoration
  static BoxDecoration primaryGradientDecoration({double radius = AppSpacing.radiusLg}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppColors.buttonShadow,
    );
  }

  /// Premium gold gradient decoration
  static BoxDecoration premiumGradientDecoration({double radius = AppSpacing.radiusLg}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: AppColors.premiumGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppColors.premiumButtonShadow,
    );
  }

  /// Subtle filled chip decoration (for tags, badges)
  static BoxDecoration chipDecoration(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant);
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
    );
  }
}
