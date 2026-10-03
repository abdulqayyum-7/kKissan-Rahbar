import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../constants/app_theme.dart';
import '../constants/routes.dart';

const _pakistanGreen = Color(0xFF0F5B3E);
const _harvestGold = Color(0xFFF0C45A);
const _warmPaper = Color(0xFFF5F1E5);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _warmPaper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                color: _pakistanGreen,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAKISTAN’S FARMING COMPANION',
                            style: AppFonts.body(11, const Color(0xFFE6F0E9), weight: FontWeight.w700, letterSpacing: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Container(width: 40, height: 4, color: _harvestGold),
                          const SizedBox(height: 16),
                          Text(
                            kAppName,
                            style: AppFonts.heading(32, Colors.white, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'پاکستانی کسانوں کے لیے، اردو میں رہنمائی',
                            textDirection: TextDirection.rtl,
                            style: AppFonts.body(20, Colors.white, weight: FontWeight.w600, height: 1.55),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Practical farming advice shaped for Pakistan’s crops, seasons and growing regions.',
                            style: AppFonts.body(14, const Color(0xFFE6F0E9), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _Feature(icon: Icons.grass_outlined, label: 'Crops'),
                        _Feature(icon: Icons.pest_control_outlined, label: 'Pest advice'),
                        _Feature(icon: Icons.mic_none_rounded, label: 'Voice questions'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      title: 'Log in',
                      height: 52,
                      onPressed: () => Navigator.pushNamed(context, Routes.login),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      title: 'Register',
                      height: 52,
                      filled: false,
                      onPressed: () => Navigator.pushNamed(context, Routes.register),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: _pakistanGreen),
          const SizedBox(width: 6),
          Text(label, style: AppFonts.body(12, _pakistanGreen, weight: FontWeight.w600)),
        ]),
      );
}
