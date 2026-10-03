import 'package:flutter/material.dart';

import '../constants/app_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.filled = true,
    this.isLoading = false,
    this.icon,
    this.color,
    this.height = 60,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool filled;
  final bool isLoading;
  final IconData? icon;
  final Color? color; // overrides the brand green (e.g. danger)
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    final base = color ?? AppColors.primary;
    final fg = filled ? Colors.white : base;
    final enabled = onPressed != null && !isLoading;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: filled ? base : Colors.transparent,
        borderRadius: radius,
        border: filled ? null : Border.all(color: base, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: enabled ? onPressed : null,
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[Icon(icon, color: fg, size: 22), const SizedBox(width: 8)],
                      Text(title, style: AppFonts.heading(19, fg, weight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
