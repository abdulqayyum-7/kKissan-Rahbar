import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../components/app_input.dart';
import '../components/auth_scaffold.dart';
import '../constants/app_theme.dart';
import '../constants/routes.dart';
import '../themes/theme_colors.dart';
import '../utils/dialogs.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Map<String, String> _values = {'email': '', 'password': ''};
  final Map<String, String?> _errors = {};
  bool _isLoading = false;

  void _onInputChanged(String id, String value) {
    setState(() {
      _values[id] = value;
      _errors[id] = validateInput(id, value);
    });
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _values['email']!.trim(),
        password: _values['password']!,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(context, Routes.tabs, (r) => false);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'wrong-password' || 'user-not-found' || 'invalid-credential' => 'Wrong email or password',
        'invalid-email' => 'Enter a valid email address',
        'network-request-failed' => 'No internet connection. Check your network and try again',
        'too-many-requests' => 'Too many attempts. Try again later',
        'operation-not-allowed' => 'Email/Password sign-in is not enabled in Firebase',
        _ => 'Something went wrong',
      };
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorDialog(context, 'An error occurred', message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final message = e.toString().contains('no-app')
          ? "Firebase isn't set up. Run: flutterfire configure"
          : 'Something went wrong';
      showErrorDialog(context, 'An error occurred', message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Login to your account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            hintText: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            errorText: _errors['password'],
            onInputChanged: _onInputChanged,
          ),
          const SizedBox(height: 8),
          AppButton(title: 'Login', isLoading: _isLoading, onPressed: _login),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: AppFonts.body(15, c.muted)),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, Routes.register),
                child: Text(
                  'Register',
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
