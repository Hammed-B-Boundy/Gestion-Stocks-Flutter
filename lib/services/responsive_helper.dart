import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double getAdaptiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return baseSize * 0.8;
    } else if (isTablet(context)) {
      return baseSize * 1.0;
    } else {
      return baseSize * 1.2;
    }
  }

  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  static double getAdaptiveIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 32.0;
    } else {
      return 40.0;
    }
  }

  static Widget getResponsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static double getAdaptiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 24.0;
    }
  }

  static BoxConstraints getAdaptiveConstraints(BuildContext context) {
    if (isMobile(context)) {
      return const BoxConstraints(maxWidth: 600);
    } else if (isTablet(context)) {
      return const BoxConstraints(maxWidth: 1200);
    } else {
      return const BoxConstraints(maxWidth: double.infinity);
    }
  }
}
