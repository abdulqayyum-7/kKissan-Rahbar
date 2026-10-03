import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../themes/theme_colors.dart';
import 'circle_icon_button.dart';
import 'logo_badge.dart';

/// Light brand page shared by the sign-in and account creation forms.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Navigator.canPop(context)
                            ? CircleIconButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onPressed: () => Navigator.maybePop(context),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(child: LogoMark(size: 88)),
                    const SizedBox(height: 24),
                    Text(title, textAlign: TextAlign.center, style: AppFonts.heading(30, c.text)),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(15.5, c.muted, height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
