import 'package:flutter/material.dart';

extension BrightnessExtensions on Brightness {
  bool get isDark => this == Brightness.dark;
  Color get textColor => isDark ? Colors.white : Colors.black;
  Color get textColor2 => isDark ? Colors.white70 : Colors.black87;

  Color get getBackgroundColor => isDark ? Colors.grey[800]! : Colors.grey[200]!;
  Color get getAltBackgroundColor => isDark ? Colors.grey[900]! : Colors.grey[300]!;
  Color get getAlt2BackgroundColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;

  TextTheme get textTheme => TextTheme(
        bodyText1: TextStyle(fontSize: 16, color: textColor),
        bodyText2: TextStyle(fontSize: 14, color: textColor),
        headline1: TextStyle(
          fontSize: 24,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        headline2: TextStyle(
          fontSize: 22,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        headline3: TextStyle(
          fontSize: 20,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        headline4: TextStyle(
          fontSize: 18,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        headline5: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        headline6: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      );
}
