// One-command setup + run.
//
//   dart tool/setup.dart --key=YOUR_GEMINI_KEY
//
// Works on Windows, macOS and Linux. Safe to run again at any time.
import 'dart:io';

Future<int> run(String cmd, List<String> args) async {
  stdout.writeln('\n> $cmd ${args.join(' ')}');
  final p = await Process.start(cmd, args,
      runInShell: true, mode: ProcessStartMode.inheritStdio);
  return p.exitCode;
}

Future<bool> available(String cmd, List<String> args) async {
  try {
    final r = await Process.run(cmd, args, runInShell: true);
    return r.exitCode == 0;
  } catch (_) {
    return false;
  }
}

void step(String text) => stdout.writeln('\n==== $text ====');

void patchManifest() {
  final f = File('android/app/src/main/AndroidManifest.xml');
  if (!f.existsSync()) return;
  var s = f.readAsStringSync();
  if (!s.contains('android.permission.INTERNET')) {
    s = s.replaceFirst('<application',
        '<uses-permission android:name="android.permission.INTERNET"/>\n    <application');
    f.writeAsStringSync(s);
    stdout.writeln('Added INTERNET permission.');
  }
}

void patchGradle() {
  for (final path in ['android/app/build.gradle.kts', 'android/app/build.gradle']) {
    final f = File(path);
    if (!f.existsSync()) continue;
    final s = f.readAsStringSync();
    final out = s.replaceAllMapped(
      RegExp(r'(minSdk(?:Version)?)(\s*=?\s*)flutter\.minSdkVersion'),
      (m) => '${m[1]}${m[2]}23',
    );
    if (out != s) {
      f.writeAsStringSync(out);
      stdout.writeln('Set minSdk to 23 in $path.');
    }
  }
}

bool firebaseConfigured() {
  final f = File('lib/firebase_options.dart');
  return f.existsSync() &&
      !f.readAsStringSync().contains('Firebase is not configured for this platform');
}

Never fail(String message) {
  stderr.writeln('\nSTOPPED: $message');
  exit(1);
}

Future<void> main(List<String> args) async {
  String key = '';
  for (final a in args) {
    if (a.startsWith('--key=')) key = a.substring(6);
  }

  if (!File('pubspec.yaml').existsSync()) {
    fail('Run this from the farmergist folder (the one containing pubspec.yaml).');
  }
  if (!await available('flutter', ['--version'])) {
    fail('Flutter was not found. Install it and add it to PATH.');
  }

  step('1/6 Android project');
  if (!Directory('android').existsSync()) {
    final code = await run('flutter', [
      'create', '.', '--org', 'com.farmergist',
      '--project-name', 'farmergist', '--platforms=android',
    ]);
    if (code != 0) fail('flutter create failed.');
  } else {
    stdout.writeln('android/ already exists, skipping.');
  }
  final defaultTest = File('test/widget_test.dart');
  if (defaultTest.existsSync()) defaultTest.deleteSync();
  patchManifest();
  patchGradle();

  step('2/6 Packages');
  if (await run('flutter', ['pub', 'get']) != 0) fail('flutter pub get failed.');

  step('3/6 App icon');
  await run('dart', ['run', 'flutter_launcher_icons']);

  step('4/6 Splash screen');
  await run('dart', ['run', 'flutter_native_splash:create']);

  step('5/6 Firebase');
  if (firebaseConfigured()) {
    stdout.writeln('Firebase already configured (lib/firebase_options.dart).');
  } else {
    if (!await available('firebase', ['--version'])) {
      fail('Firebase CLI missing. Run: npm install -g firebase-tools   then: firebase login\n'
          'Then run this script again.');
    }
    if (!await available('flutterfire', ['--version'])) {
      await run('dart', ['pub', 'global', 'activate', 'flutterfire_cli']);
    }
    stdout.writeln('Pick YOUR Firebase project when asked (log in first with: firebase login).');
    final code = await run('flutterfire', ['configure', '--platforms=android']);
    if (code != 0 || !firebaseConfigured()) {
      fail('flutterfire configure did not finish. Run: firebase login   then run this script again.');
    }
  }

  step('6/6 Run');
  if (key.isEmpty) {
    stdout.writeln('Setup done. Start the app with:\n'
        '  flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY');
    return;
  }
  exit(await run('flutter', ['run', '--dart-define=GEMINI_API_KEY=$key']));
}
