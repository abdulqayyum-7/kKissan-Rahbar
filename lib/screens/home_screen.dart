import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/logo_badge.dart';
import '../constants/app_theme.dart';
import '../constants/examples.dart';
import '../themes/theme_colors.dart';
import 'chat_screen.dart';

const _pakistanGreen = Color(0xFF0F5B3E);
const _harvestGold = Color(0xFFF0C45A);

void _openChat(BuildContext context, [String? question]) {
  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChatScreen(initialQuestion: question)));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(children: [
              const LogoMark(size: 36),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(kAppName, style: AppFonts.heading(18, c.text)),
                Text('FARMING ASSISTANT', style: AppFonts.body(11, c.muted, weight: FontWeight.w600)),
              ])),
              IconButton.filledTonal(
                tooltip: 'Start a new chat',
                onPressed: () => _openChat(context),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.add_rounded),
              ),
            ]),
          ),
          Divider(height: 1, color: c.border),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _pakistanGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 36, height: 4, color: _harvestGold),
                      const SizedBox(height: 16),
                      Text(
                        'Farming advice\nfor Pakistan.',
                        style: AppFonts.heading(29, Colors.white, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask about crops, pests, livestock and water. Get practical guidance for your region.',
                        style: AppFonts.body(14, const Color(0xFFE6F0E9), height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'جواب اردو میں ملے گا',
                        textDirection: TextDirection.rtl,
                        style: AppFonts.body(15, Colors.white, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Text('START WITH A QUESTION', style: AppFonts.body(11, c.muted, weight: FontWeight.w700, letterSpacing: 0.4)),
                  const Spacer(),
                  Text('Select a topic', style: AppFonts.body(12, c.muted)),
                ]),
                const SizedBox(height: 12),
                for (var i = 0; i < kExamples.length; i++)
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: _QuestionCard(
                    index: i + 1,
                    question: kExamples[i].question,
                    hint: kExamples[i].hint,
                    onTap: () => _openChat(context, kExamples[i].question),
                  )),
                const SizedBox(height: 16),
                AppButton(title: 'Ask your own question', icon: Icons.edit_outlined, onPressed: () => _openChat(context), height: 52),
              ]),
            )),
          )),
        ]),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.index, required this.question, required this.hint, required this.onTap});
  final int index;
  final String question;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(color: c.background, borderRadius: BorderRadius.circular(8), child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(8)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 28, child: Text(index.toString().padLeft(2, '0'), style: AppFonts.body(12, AppColors.primary, weight: FontWeight.w700))),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(question, style: AppFonts.body(14, c.text, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(hint, style: AppFonts.body(12, c.muted, height: 1.4)),
          ])),
          const SizedBox(width: 4),
          Icon(Icons.arrow_outward_rounded, size: 17, color: c.muted),
        ]),
      ),
    ));
  }
}
