/// Pass at run time:
///   flutter run --dart-define=GEMINI_API_KEY=your_key
const String kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

/// Optional. Leave empty: the app asks Google which Flash models your key can
/// use and picks the newest one automatically (see GeminiChatService).
/// Force one with: --dart-define=GEMINI_MODEL=<model>
const String kGeminiModel = String.fromEnvironment('GEMINI_MODEL');
