import 'dart:typed_data';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    this.imageBytes,
    this.imageMimeType,
    DateTime? createdAt,
  })
      : createdAt = createdAt ?? DateTime.now();

  final String text;
  final bool isUser;
  final Uint8List? imageBytes;
  final String? imageMimeType;
  final DateTime createdAt;
}
