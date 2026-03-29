import 'package:flutter/material.dart';

enum MyDeviceType { mobile, tablet, desktop }

class Responsive {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static MyDeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return MyDeviceType.mobile;
    if (width < tabletBreakpoint) return MyDeviceType.tablet;
    return MyDeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
    getDeviceType(context) == MyDeviceType.mobile;

  static bool isTablet(BuildContext context) =>
    getDeviceType(context) == MyDeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
    getDeviceType(context) == MyDeviceType.desktop;
}

extension DeviceContextExtension on BuildContext {
  MyDeviceType get myDeviceType => Responsive.getDeviceType(this);
  bool get isMobileScreen => Responsive.isMobile(this);
  bool get isTabletScreen => Responsive.isTablet(this);
  bool get isDesktopScreen => Responsive.isDesktop(this);
}
