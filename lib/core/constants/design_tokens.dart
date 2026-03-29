import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 56;
  static const double sectionGap = 28;
  static const double pagePadding = 24;
  static const double pageMaxWidth = 1240;
  static const double authFormWidth = 520;
}

abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;
}

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x12121212), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x1A1C1E22), blurRadius: 40, offset: Offset(0, 18)),
  ];
}

abstract final class AppDurations {
  static const short = Duration(milliseconds: 250);
  static const medium = Duration(milliseconds: 450);
  static const long = Duration(milliseconds: 700);
}

abstract final class AppDefaults {
  static const String apiBaseUrl = 'https://api.elearning.dev';
}
