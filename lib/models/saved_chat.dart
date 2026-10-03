import 'dart:convert';

import 'chat_message.dart';

class SavedChat {
  SavedChat({
    required this.id,
    required this.title,
    required this.messages,
    required this.savedAt,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages; // chronological
  final DateTime savedAt;

  String get preview {
    for (final m in messages.reversed) {
      if (!m.isUser) return m.text;
    }
    return messages.isEmpty ? '' : messages.last.text;
  }

  Map<String, Object?> toMap() => {
        'title': title,
        'savedAt': savedAt.millisecondsSinceEpoch,
        'messages': [
          for (final m in messages)
            {
              't': m.text,
              'u': m.isUser,
              'at': m.createdAt.millisecondsSinceEpoch,
              if (m.imageBytes != null) 'img': base64Encode(m.imageBytes!),
              if (m.imageMimeType != null) 'mime': m.imageMimeType,
            },
        ],
      };

  static SavedChat? tryParse(String id, Map<dynamic, dynamic> map) {
    try {
      final raw = map['messages'];
      final list = raw is List ? raw : (raw is Map ? raw.values.toList() : const []);
      final messages = <ChatMessage>[
        for (final m in list)
          if (m is Map)
            ChatMessage(
              text: (m['t'] ?? '').toString(),
              isUser: m['u'] == true,
              imageBytes: (m['img'] as String?)?.isNotEmpty == true
                  ? base64Decode(m['img'] as String)
                  : null,
              imageMimeType: m['mime'] as String?,
              createdAt: DateTime.fromMillisecondsSinceEpoch((m['at'] as num?)?.toInt() ?? 0),
            ),
      ];
      return SavedChat(
        id: id,
        title: (map['title'] ?? 'Chat').toString(),
        messages: messages,
        savedAt: DateTime.fromMillisecondsSinceEpoch((map['savedAt'] as num?)?.toInt() ?? 0),
      );
    } catch (_) {
      return null;
    }
  }
}
