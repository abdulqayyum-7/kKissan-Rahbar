import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../themes/theme_colors.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.id,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onInputChanged,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
  });

  final String id;
  final String label;
  final String hintText;
  final IconData icon;
  final void Function(String id, String text) onInputChanged;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _hidden = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppFonts.body(14, c.text, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (t) => widget.onInputChanged(widget.id, t),
            obscureText: _hidden,
            keyboardType: widget.keyboardType,
            cursorColor: AppColors.primary,
            style: AppFonts.body(16, c.text),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppFonts.body(15, c.muted),
              filled: true,
              fillColor: c.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(widget.icon, color: c.muted, size: 22),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: c.muted,
                        size: 22,
                      ),
                    )
                  : null,
              errorText: widget.errorText,
              errorStyle: AppFonts.body(12.5, AppColors.danger),
              border: border(c.border),
              enabledBorder: border(c.border),
              focusedBorder: border(AppColors.primary, 1.8),
              errorBorder: border(AppColors.danger),
              focusedErrorBorder: border(AppColors.danger, 1.8),
            ),
          ),
        ],
      ),
    );
  }
}
