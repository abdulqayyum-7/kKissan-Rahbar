import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';

import '../components/chat_bubble.dart';
import '../components/circle_icon_button.dart';
import '../components/logo_badge.dart';
import '../components/typing_indicator.dart';
import '../config/env.dart';
import '../constants/app_theme.dart';
import '../constants/examples.dart';
import '../models/chat_message.dart';
import '../models/saved_chat.dart';
import '../services/gemini_chat_service.dart';
import '../services/saved_chats_controller.dart';
import '../themes/theme_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.initialQuestion, this.saved});

  /// Sent automatically when the screen opens (e.g. from an example card).
  final String? initialQuestion;

  /// Opens an existing saved chat.
  final SavedChat? saved;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _speechChannel = MethodChannel('com.kissanrahbar.app/speech');
  final TextEditingController _input = TextEditingController();
  final List<ChatMessage> _messages = []; // newest first (list is reversed)
  final GeminiChatService _service = GeminiChatService();
  late final String _chatId =
      widget.saved?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
  bool _isTyping = false;
  bool _isListening = false;
  Uint8List? _pendingImageBytes;
  String _pendingImageMimeType = 'image/jpeg';
  Uint8List? _failedImageBytes;
  String? _failedImageMimeType;
  String? _chatError;
  String? _failedText;

  @override
  void initState() {
    super.initState();
    final saved = widget.saved;
    if (saved != null) {
      _messages.addAll(saved.messages.reversed);
      _service.restoreHistory(saved.messages);
    }
    final q = widget.initialQuestion;
    if (q != null && q.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _generate(q.trim()));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  List<ChatMessage> get _chronological => _messages.reversed.toList();

  SavedChat _snapshot() {
    final chrono = _chronological;
    final first = chrono.firstWhere((m) => m.isUser, orElse: () => chrono.first);
    final title = first.text.trim();
    return SavedChat(
      id: _chatId,
      title: title.length > 60 ? '${title.substring(0, 60)}...' : title,
      messages: chrono,
      savedAt: DateTime.now(),
    );
  }

  void _syncSaved() {
    if (!mounted || _messages.isEmpty) return;
    final saved = context.read<SavedChatsController>();
    if (saved.isSaved(_chatId)) saved.save(_snapshot());
  }

  void _toggleSave() {
    final saved = context.read<SavedChatsController>();
    final messenger = ScaffoldMessenger.of(context);
    String text;
    if (_messages.isEmpty) {
      text = 'Send a message first';
    } else if (saved.isSaved(_chatId)) {
      saved.remove(_chatId);
      text = 'Removed from saved';
    } else {
      saved.save(_snapshot());
      text = 'Chat saved';
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _generate(
    String text, {
    bool retry = false,
    Uint8List? imageBytes,
    String imageMimeType = 'image/jpeg',
  }) async {
    if (_isTyping) return;

    if (kGeminiApiKey.isEmpty) {
      setState(() => _chatError = 'Chat is not configured yet. Add a Gemini API key and try again.');
      return;
    }

    setState(() {
      _isTyping = true;
      _chatError = null;
      _failedText = null;
      _failedImageBytes = null;
      _failedImageMimeType = null;
      if (!retry) {
        _messages.insert(0, ChatMessage(
          text: text,
          isUser: true,
          imageBytes: imageBytes,
          imageMimeType: imageBytes == null ? null : imageMimeType,
        ));
      }
    });

    try {
      final reply = await _service.send(
        text,
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );
      if (!mounted) return;
      if (reply == null) {
        setState(() {
          _chatError = 'We couldn’t read a reply. Please try again.';
          _failedText = text;
          _failedImageBytes = imageBytes;
          _failedImageMimeType = imageBytes == null ? null : imageMimeType;
        });
      } else {
        setState(() {
          _messages.insert(0, ChatMessage(text: reply, isUser: false));
          _pendingImageBytes = null;
          _pendingImageMimeType = 'image/jpeg';
        });
        _input.clear();
      }
    } catch (e) {
      if (!mounted) return;
      var message = e is GenerativeAIException ? e.message : e.toString();
      if (message.contains('503') || message.contains('UNAVAILABLE')) {
        message = 'Gemini is busy right now. Please try again in a moment.';
      } else if (message.contains('SocketException') || message.contains('Failed host lookup') || message.contains('timed out')) {
        message = 'Could not reach the chat service. Check your connection and try again.';
      } else if (message.contains('401') || message.contains('403') || message.contains('API key')) {
        message = 'The chat service rejected its API key. Please check the app configuration.';
      }
      setState(() {
        _chatError = message.isEmpty ? 'Your message wasn’t sent. Check your connection and try again.' : message;
        _failedText = text;
        _failedImageBytes = imageBytes;
        _failedImageMimeType = imageBytes == null ? null : imageMimeType;
      });
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
        _syncSaved();
      }
    }
  }

  void _submit() {
    final text = _input.text.trim();
    final imageBytes = _pendingImageBytes;
    if (text.isEmpty && imageBytes == null) return;
    final prompt = text.isNotEmpty
        ? text
        : 'اس تصویر میں موجود فصل یا کیڑے کے بارے میں رہنمائی کریں۔';
    _generate(
      prompt,
      imageBytes: imageBytes,
      imageMimeType: _pendingImageMimeType,
    );
  }

  Future<void> _pickImage() async {
    if (_isTyping || _isListening) return;
    try {
      final attachment = await _speechChannel.invokeMapMethod<String, dynamic>('pickImage');
      if (!mounted || attachment == null) return;
      final bytes = attachment['bytes'];
      if (bytes is! Uint8List || bytes.isEmpty) {
        throw const FormatException('The selected photo could not be read. Choose another image.');
      }
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        throw const FormatException('This photo is too large to attach. Choose a smaller image.');
      }
      setState(() {
        _pendingImageBytes = bytes;
        _pendingImageMimeType = attachment['mimeType'] as String? ?? 'image/jpeg';
        _chatError = null;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      _showAttachmentError(e.message ?? 'Could not open the photo. Try again.');
    } on MissingPluginException {
      if (!mounted) return;
      _showAttachmentError('Photo attachments are available on Android devices.');
    } on FormatException catch (e) {
      if (!mounted) return;
      _showAttachmentError(e.message);
    }
  }

  void _showAttachmentError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _listen() async {
    if (_isListening || _isTyping) return;
    setState(() => _isListening = true);
    try {
      final transcript = await _speechChannel.invokeMethod<String>('listen', {'locale': 'ur-PK'});
      if (!mounted) return;
      if (transcript != null && transcript.trim().isNotEmpty) {
        _input.value = TextEditingValue(
          text: transcript.trim(),
          selection: TextSelection.collapsed(offset: transcript.trim().length),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message ?? 'Voice input is unavailable.')));
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Voice input is available on Android devices.')));
    } finally {
      if (mounted) setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isSaved = context.watch<SavedChatsController>().isSaved(_chatId);
    final itemCount = _messages.length + (_isTyping ? 1 : 0);
    final empty = itemCount == 0;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 12),
                  const LogoMark(size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kAppName, style: AppFonts.heading(19, c.text)),
                        Text(
                          _isTyping ? 'سوچ رہا ہوں' : 'پاکستانی زراعت · اردو',
                          style: AppFonts.body(11, AppColors.primary,
                              weight: FontWeight.w600, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                  CircleIconButton(
                    icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? AppColors.primary : null,
                    onPressed: _toggleSave,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border),

            // Messages
            Expanded(
              child: empty
                  ? _EmptyChat(onPick: _generate)
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: itemCount,
                      itemBuilder: (context, i) {
                        if (_isTyping && i == 0) return const TypingIndicator();
                        return ChatBubble(message: _messages[_isTyping ? i - 1 : i]);
                      },
                    ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: c.background,
                border: Border(top: BorderSide(color: c.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_pendingImageBytes != null) ...[
                    _AttachedImage(
                      bytes: _pendingImageBytes!,
                      onRemove: _isTyping
                          ? null
                          : () => setState(() {
                                _pendingImageBytes = null;
                                _pendingImageMimeType = 'image/jpeg';
                              }),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_chatError != null) ...[
                    _ChatError(
                      message: _chatError!,
                      onRetry: _failedText == null
                          ? null
                          : () => _generate(
                                _failedText!,
                                retry: true,
                                imageBytes: _failedImageBytes,
                                imageMimeType: _failedImageMimeType ?? 'image/jpeg',
                              ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'Attach a crop or pest photo',
                        child: Material(
                          color: c.surface,
                          shape: CircleBorder(side: BorderSide(color: c.border)),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _isTyping || _isListening ? null : _pickImage,
                            child: SizedBox(
                              width: 44,
                              height: 48,
                              child: Icon(Icons.add_photo_alternate_outlined, color: c.text, size: 21),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Speak your question',
                        child: Material(
                          color: c.surface,
                          shape: CircleBorder(side: BorderSide(color: c.border)),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _isTyping || _isListening ? null : _listen,
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                _isListening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                                color: _isListening ? AppColors.primary : c.text,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: c.border),
                          ),
                          child: TextField(
                            controller: _input,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _submit(),
                            cursorColor: AppColors.primary,
                            style: AppFonts.body(15, c.text),
                            decoration: InputDecoration(
                              hintText: _pendingImageBytes == null ? 'Enter your question' : 'Ask about the photo',
                              hintStyle: AppFonts.body(15, c.muted),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Send message',
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _isTyping ? null : _submit,
                              child: Icon(
                                _isTyping ? Icons.hourglass_top_rounded : Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatError extends StatelessWidget {
  const _ChatError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(color: const Color(0xFFFFF4F2), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFFB42318), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: AppFonts.body(12.5, const Color(0xFF7A271A)))),
        if (onRetry != null)
          TextButton(onPressed: onRetry, style: TextButton.styleFrom(foregroundColor: c.text), child: const Text('Retry')),
      ]),
    );
  }
}

class _AttachedImage extends StatelessWidget {
  const _AttachedImage({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(bytes, width: 52, height: 52, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text('Photo attached · crop or pest', style: AppFonts.body(13, c.text))),
        IconButton(
          tooltip: 'Remove photo',
          onPressed: onRemove,
          icon: Icon(Icons.close_rounded, color: c.muted, size: 20),
          visualDensity: VisualDensity.compact,
        ),
      ]),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoMark(size: 84),
            const SizedBox(height: 18),
            Text('پاکستان میں زراعت کے بارے میں پوچھیں', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: AppFonts.heading(21, c.text)),
            const SizedBox(height: 8),
            Text(
              'اپنا سوال لکھیں یا آواز سے پوچھیں۔ جواب اردو میں ملے گا۔',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppFonts.body(14.5, c.muted, height: 1.4),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final e in kExamples)
                  ActionChip(
                    onPressed: () => onPick(e.question),
                    label: Text(e.question,
                        style: AppFonts.body(13.5, c.text, weight: FontWeight.w500)),
                    backgroundColor: c.surface,
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
