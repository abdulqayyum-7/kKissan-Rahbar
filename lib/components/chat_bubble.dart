import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/chat_message.dart';
import '../utils/time.dart';
import 'logo_badge.dart';

/// Compact chat bubbles use neutral surfaces and the shared forest accent.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.74;
    final time = formatTime(message.createdAt);

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.fromLTRB(48, 6, 16, 6),
          padding: const EdgeInsets.fromLTRB(15, 11, 15, 8),
          decoration: const BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.imageBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    message.imageBytes!,
                    width: maxWidth - 30,
                    height: 168,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 180,
                      height: 120,
                      child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(message.text, style: AppFonts.body(14.5, Colors.white, height: 1.45)),
              const SizedBox(height: 4),
              Text(time, style: AppFonts.body(11, Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LogoMark(size: 32),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.fromLTRB(15, 11, 15, 8),
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.text, style: AppFonts.body(14.5, AppColors.black, height: 1.5)),
                  const SizedBox(height: 4),
                  Text(time, style: AppFonts.body(10, AppColors.inactive)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
