import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../constants/app_theme.dart';
import '../themes/theme_colors.dart';

Future<void> showErrorDialog(BuildContext context, String title, String message) {
  final c = context.colors;
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: c.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.danger.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: AppFonts.heading(22, c.text)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(14.5, c.muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            AppButton(title: 'OK', height: 52, onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}
