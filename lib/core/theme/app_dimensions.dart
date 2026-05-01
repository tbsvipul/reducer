/// Design tokens for dimensions, spacing, radius, and elevation.
///
/// This class centralizes all numeric UI values to ensure consistency and
/// eliminate hardcoded values in widgets.
abstract final class AppDimensions {
  // ── Spacing ───────────────────────────────────────────────────────────────────
  static const double xs2 = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
  static const double xl6 = 64.0;

  // ── Border Radius ─────────────────────────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXl2 = 24.0;
  static const double radiusXl3 = 32.0;
  static const double radiusFull = 999.0;

  // ── Elevation ─────────────────────────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;

  // ── Icon Sizes ────────────────────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXl2 = 48.0;
  static const double iconXl3 = 64.0;
  static const double iconXl4 = 80.0;

  // ── Padding Sets ──────────────────────────────────────────────────────────────
  static const double pagePadding = xl2;
  static const double cardPadding = lg;
  static const double sectionPadding = xl3;
}
