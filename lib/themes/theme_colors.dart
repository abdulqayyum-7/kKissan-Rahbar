import 'package:flutter/material.dart';

class ThemeColors {
  const ThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color muted;
  final Color border;

  static const light = ThemeColors(
    background: Color(0xFFFCFDFC),
    surface: Color(0xFFF3F5F3),
    surfaceAlt: Color(0xFFEAEEEB),
    text: Color(0xFF17211C),
    muted: Color(0xFF526159),
    border: Color(0xFFDCE3DE),
  );

}

extension ThemeContext on BuildContext {
  ThemeColors get colors => ThemeColors.light;
}
