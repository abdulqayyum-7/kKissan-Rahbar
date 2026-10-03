import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../components/app_input.dart';
import '../components/auth_scaffold.dart';
import '../constants/app_theme.dart';
import '../constants/routes.dart';
import '../themes/theme_colors.dart';
import '../utils/dialogs.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Map<String, String> _values = {'fullName': '', 'email': '', 'password': ''};
  final Map<String, String?> _errors = {};
  bool _isLoading = false;

  void _onInputChanged(String id, String value) {
    setState(() {
      _values[id] = value;
      _errors[id] = validateInput(id, value);
    });
  }

  Future<void> _createUser(String fullName, String email, String userId) {
    final userData = {
      'fullName': fullName,
      'email': email,
      'userId': userId,
      'signUpDate': DateTime.now().toUtc().toIso8601String(),
    };
    return FirebaseDatabase.instance.ref('users/$userId').update(userData);
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      final email = _values['email']!.trim();
      final fullName = _values['fullName']!.trim();
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _values['password']!,
      );

      try {
        await result.user!.updateDisplayName(fullName);
      } catch (e) {
        debugPrint('Setting display name failed: $e');
      }

      try {
        await _createUser(fullName, email, result.user!.uid).timeout(const Duration(seconds: 10));
      } catch (e) {
        // The account exists already; don't block sign-up if the profile write
        // fails (database not created, rules, offline...).
        debugPrint('Saving user profile failed: $e');
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(context, Routes.tabs, (r) => false);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'This email is already in use',
        'weak-password' => 'Password is too weak',
        'invalid-email' => 'Enter a valid email address',
        'network-request-failed' => 'No internet connection. Check your network and try again',
        'operation-not-allowed' => 'Email/Password sign-in is not enabled in Firebase',
        _ => 'Something went wrong.',
      };
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorDialog(context, 'An error occurred', message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final message = e.toString().contains('no-app')
          ? "Firebase isn't set up. Run: flutterfire configure"
          : 'Something went wrong.';
      showErrorDialog(context, 'An error occurred', message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join $kAppName and start growing smarter',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            id: 'fullName',
            label: 'Full name',
            hintText: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            errorText: _errors['fullName'],
            onInputChanged: _onInputChanged,
          ),
          AppInput(
            id: 'email',
            label: 'Email',
            hintText: 'Enter your email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            errorText: _errors['email'],
            onInputChanged: _onInputChanged,
          ),
          AppInput(
            id: 'password',
            label: 'Password',
            hintText: 'At least 6 characters',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            errorText: _errors['password'],
            onInputChanged: _onInputChanged,
          ),
          const SizedBox(height: 8),
          AppButton(title: 'Register', isLoading: _isLoading, onPressed: _register),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account? ', style: AppFonts.body(15, c.muted)),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, Routes.login),
                child: Text(
                  'Login',
                  style: AppFonts.body(15, AppColors.primary, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
