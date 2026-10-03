import 'package:flutter/material.dart';

import '../themes/theme_colors.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    this.icon,
    required this.onPressed,
    this.color,
    this.size = 44,
  });

  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: CircleBorder(side: BorderSide(color: c.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, color: color ?? c.text, size: 22),
          ),
        ),
      ),
    );
  }
}
