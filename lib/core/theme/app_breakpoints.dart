import 'package:flutter/material.dart';

final class AppBreakpoints {
  static const double compact = 600;
  static const double expanded = 840;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < expanded;
  }

  static bool useNavigationRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;

  static double contentMaxWidth(
    BuildContext context, {
    double compactWidth = 640,
    double mediumWidth = 760,
    double expandedWidth = 960,
  }) {
    if (useNavigationRail(context)) {
      return expandedWidth;
    }
    if (isMedium(context)) {
      return mediumWidth;
    }
    return compactWidth;
  }
}
