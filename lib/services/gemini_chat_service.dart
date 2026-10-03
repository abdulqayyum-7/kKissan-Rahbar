import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/env.dart';
import '../config/prompts.dart';
import '../models/chat_message.dart';

/// Chat with Gemini that survives model retirements and overload:
///  1. asks the API which `gemini-X-flash` models this key can use (newest first),
///  2. retries temporary 503 / 429 errors with a short backoff,
///  3. falls back to the next model if one is overloaded or no longer available.
class GeminiChatService {
  static const _delays = [Duration(seconds: 2), Duration(seconds: 4)];

  final List<Content> _history = [
    Content('user', [TextPart(kSeedPrompt)]),
    Content('model', [TextPart(kSeedAck)]),
  ];

  List<String>? _candidates;
  int _modelIndex = 0;

  /// Restores earlier turns (e.g. from a saved chat) so replies keep context.
  /// Only complete user -> model pairs are kept so turns always alternate.
  void restoreHistory(List<ChatMessage> chronological) {
    for (var i = 0; i < chronological.length - 1; i++) {
      final a = chronological[i];
      final b = chronological[i + 1];
      if (a.isUser && !b.isUser) {
        final userParts = <Part>[TextPart(a.text)];
        if (a.imageBytes != null) {
          userParts.add(DataPart(a.imageMimeType ?? 'image/jpeg', a.imageBytes!));
        }
        _history
          ..add(Content('user', userParts))
          ..add(Content('model', [TextPart(b.text)]));
        i++;
      }
    }
  }

  /// Returns the cleaned reply text, or null when the API returned no text.
  Future<String?> send(
    String message, {
    Uint8List? imageBytes,
    String imageMimeType = 'image/jpeg',
  }) async {
    final models = await _loadCandidates();
    Object? lastError;

    for (var m = _modelIndex; m < models.length; m++) {
      for (var attempt = 0; attempt <= _delays.length; attempt++) {
        try {
          final model = GenerativeModel(model: models[m], apiKey: kGeminiApiKey);
          final chat = model.startChat(history: List<Content>.of(_history));
          final parts = <Part>[TextPart(message)];
          if (imageBytes != null) parts.add(DataPart(imageMimeType, imageBytes));
          final content = Content.multi(parts);
          final response = await chat.sendMessage(content);
          final raw = response.text;
          _modelIndex = m;
          if (raw == null) return null;
          _history
            ..add(content)
            ..add(Content('model', [TextPart(raw)]));
          return cleanMarkdown(raw.trim());
        } catch (e) {
          lastError = e;
          if (_isTemporary(e) && attempt < _delays.length) {
            await Future<void>.delayed(_delays[attempt]);
            continue;
          }
          if (_isTemporary(e) || _isModelGone(e)) break; // try the next model
          rethrow;
        }
      }
    }
    throw lastError ?? StateError('No Gemini model is available for this API key.');
  }

  Future<List<String>> _loadCandidates() async {
    final cached = _candidates;
    if (cached != null) return cached;

    final list = <String>[];
    if (kGeminiModel.isNotEmpty) list.add(kGeminiModel);
    list.addAll(await _discoverFlashModels());
    list.addAll(const ['gemini-3.8-flash', 'gemini-flash-latest']);
    return _candidates = list.toSet().toList();
  }

  /// Lists `gemini-<major>[.<minor>]-flash` models that support generateContent,
  /// newest first. Returns [] if the lookup fails (fallbacks are used instead).
  Future<List<String>> _discoverFlashModels() async {
    if (kGeminiApiKey.isEmpty) return [];
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final request = await client.getUrl(Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?pageSize=200&key=$kGeminiApiKey',
      ));
      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];

      final body = await response.transform(utf8.decoder).join();
      final models = (jsonDecode(body)['models'] as List?) ?? const [];
      final pattern = RegExp(r'^models/(gemini-(\d+)(?:\.(\d+))?-flash)$');
      final found = <MapEntry<List<int>, String>>[];

      for (final m in models) {
        final name = (m['name'] as String?) ?? '';
        final methods = (m['supportedGenerationMethods'] as List?) ?? const [];
        final match = pattern.firstMatch(name);
        if (match == null || !methods.contains('generateContent')) continue;
        found.add(MapEntry(
          [int.parse(match[2]!), int.tryParse(match[3] ?? '') ?? 0],
          match[1]!,
        ));
      }

      found.sort((a, b) {
        final major = b.key[0].compareTo(a.key[0]);
        return major != 0 ? major : b.key[1].compareTo(a.key[1]);
      });
      return found.map((e) => e.value).toList();
    } catch (e) {
      debugPrint('Gemini model lookup failed: $e');
      return [];
    } finally {
      client.close(force: true);
    }
  }

  static bool _isTemporary(Object e) {
    final t = e.toString();
    return t.contains('503') ||
        t.contains('UNAVAILABLE') ||
        t.contains('429') ||
        t.contains('RESOURCE_EXHAUSTED') ||
        t.contains('high demand');
  }

  static bool _isModelGone(Object e) {
    final t = e.toString().toLowerCase();
    return t.contains('404') ||
        t.contains('not found') ||
        t.contains('no longer available') ||
        t.contains('is not supported');
  }

  /// Strips ** and * markdown emphasis markers.
  static String cleanMarkdown(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m[1]!)
        .replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m[1]!);
  }
}
