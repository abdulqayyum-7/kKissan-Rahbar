import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../models/saved_chat.dart';
import '../services/saved_chats_controller.dart';
import '../themes/theme_colors.dart';
import '../utils/time.dart';
import 'chat_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final saved = context.watch<SavedChatsController>();
    final items = saved.items;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), child: Row(children: [
          Expanded(child: Text('Saved chats', style: AppFonts.heading(24, c.text, weight: FontWeight.w600))),
          if (items.isNotEmpty) Text('${items.length}', style: AppFonts.body(13, c.muted, weight: FontWeight.w600)),
        ])),
        Divider(height: 1, color: c.border),
        Expanded(child: items.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _SavedCard(chat: items[i]),
              )
            : saved.isLoading || !saved.hasLoaded
                ? const _SavedLoading()
                : saved.loadError != null
                    ? _SavedLoadError(message: saved.loadError!, onRetry: saved.load)
                    : const _EmptySaved()),
      ])),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.chat});
  final SavedChat chat;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(color: c.background, borderRadius: BorderRadius.circular(8), child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChatScreen(saved: chat))),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(chat.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFonts.body(14, c.text, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(chat.preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppFonts.body(12, c.muted, height: 1.35)),
            const SizedBox(height: 6),
            Text(formatDate(chat.savedAt), style: AppFonts.body(11, c.muted)),
          ])),
          IconButton(
            tooltip: 'Remove saved chat',
            onPressed: () => context.read<SavedChatsController>().remove(chat.id),
            icon: Icon(Icons.delete_outline_rounded, color: c.muted),
          ),
        ]),
      ),
    ));
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary, size: 36),
        const SizedBox(height: 16),
        Text('Your saved chats will appear here', textAlign: TextAlign.center, style: AppFonts.heading(19, c.text, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Save a conversation from the chat screen to find it again later.', textAlign: TextAlign.center, style: AppFonts.body(13, c.muted, height: 1.45)),
      ],
    )));
  }
}

class _SavedLoading extends StatelessWidget {
  const _SavedLoading();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: List.generate(3, (_) => Container(
        height: 84,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 12),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 144, height: 12, color: c.surfaceAlt),
            const SizedBox(height: 8),
            Container(width: 196, height: 10, color: c.surfaceAlt),
          ])),
        ]),
      )),
    );
  }
}

class _SavedLoadError extends StatelessWidget {
  const _SavedLoadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 32, color: AppColors.inactive),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: AppFonts.body(14, c.text)),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    )));
  }
}
