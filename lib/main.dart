import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'constants/routes.dart';
import 'firebase_options.dart';
import 'services/saved_chats_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initialRoute = Routes.welcome;
  try {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } on UnsupportedError {
      // No generated options for this platform: use google-services.json.
      await Firebase.initializeApp();
    }
    // Already signed in? Go straight to the app.
    if (FirebaseAuth.instance.currentUser != null) initialRoute = Routes.tabs;
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavedChatsController()),
      ],
      child: FarmerGistApp(initialRoute: initialRoute),
    ),
  );
}
