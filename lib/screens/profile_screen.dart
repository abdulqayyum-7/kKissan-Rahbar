import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/app_button.dart';
import '../constants/app_theme.dart';
import '../constants/routes.dart';
import '../services/saved_chats_controller.dart';
import '../themes/theme_colors.dart';

const _pakistanGreen = Color(0xFF0F5B3E);
const _harvestGold = Color(0xFFF0C45A);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final saved = context.read<SavedChatsController>();
    final navigator = Navigator.of(context);
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Could not log out. Check your connection and try again.')));
      return;
    }
    saved.clear();
    navigator.pushNamedAndRemoveUntil(Routes.welcome, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final savedCount = context.watch<SavedChatsController>().items.length;
    String name = 'Farmer';
    String email = '';
    try {
      final user = FirebaseAuth.instance.currentUser;
      final displayName = user?.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) name = displayName;
      email = user?.email ?? '';
    } catch (_) {}
    final initial = name.substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Profile', style: AppFonts.heading(24, c.text, weight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Your farming assistant account', style: AppFonts.body(13, c.muted)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _pakistanGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: Text(initial, style: AppFonts.heading(28, _pakistanGreen, weight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: AppFonts.heading(20, Colors.white, weight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                email.isEmpty ? 'Your Kissan Rahbar account' : email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.body(12, const Color(0xFFE6F0E9)),
                              ),
                              const SizedBox(height: 12),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 20, height: 3, color: _harvestGold),
                                const SizedBox(width: 8),
                                Text('PAKISTAN · اردو', style: AppFonts.body(11, Colors.white, weight: FontWeight.w600)),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('YOUR FARMING SPACE', style: AppFonts.body(11, c.muted, weight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _ProfileStat(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Saved chats',
                        value: '$savedCount',
                      )),
                      const SizedBox(width: 8),
                      const Expanded(child: _ProfileStat(
                        icon: Icons.location_on_outlined,
                        label: 'Region',
                        value: 'Pakistan',
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.translate_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reply language', style: AppFonts.body(14, c.text, weight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text('AI answers are in Urdu by default', style: AppFonts.body(12, c.muted)),
                            ],
                          ),
                        ),
                        Text('اردو', textDirection: TextDirection.rtl,
                            style: AppFonts.body(16, AppColors.primary, weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    title: 'Log out',
                    filled: false,
                    color: AppColors.danger,
                    icon: Icons.logout_rounded,
                    onPressed: () => _logout(context),
                    height: 52,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppFonts.heading(18, c.text, weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFonts.body(11, c.muted)),
        ],
      ),
    );
  }
}
