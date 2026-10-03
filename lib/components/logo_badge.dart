import 'package:flutter/material.dart';

import '../constants/app_theme.dart';

/// Green rounded-square app icon with the white leaf.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 48, this.badge});

  final double size;

  /// Small pill at the bottom-right, e.g. "AI AGRI".
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      padding: EdgeInsets.all(size * 0.24),
      child: Image.asset('assets/images/leaf.png', fit: BoxFit.contain),
    );

    if (badge == null) return mark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        mark,
        Positioned(
          right: -size * 0.12,
          bottom: -size * 0.06,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              badge!,
              style: AppFonts.body(10.5, Colors.white, weight: FontWeight.w700, letterSpacing: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}
