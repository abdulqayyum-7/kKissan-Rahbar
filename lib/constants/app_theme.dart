import 'package:flutter/material.dart';

const String kAppName = 'Kissan Rahbar';

/// Neutral interface colors and the single forest-green accent.
class AppColors {
  static const primary = Color(0xFF176B4D);
  static const black = Color(0xFF17211C);
  static const lightGrey = Color(0xFFF3F5F3);
  static const ink = Color(0xFF26332D);
  static const inactive = Color(0xFF5B665F);
  static const danger = Color(0xFFB42318);

}

class AppFonts {
  static const sans = 'PlusJakartaSans'; // chat, inputs, body

  /// Headings and buttons.
  static TextStyle heading(double size, Color color, {FontWeight weight = FontWeight.w700}) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        height: 1.2,
        color: color,
        fontWeight: weight,
      );

  /// Body, chat and inputs (Plus Jakarta Sans).
  static TextStyle body(
    double size,
    Color color, {
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: weight,
      );
}
