import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_theme.dart';
import 'constants/routes.dart';
import 'screens/bottom_tab_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'themes/theme_colors.dart';

class FarmerGistApp extends StatelessWidget {
  const FarmerGistApp({super.key, this.initialRoute = Routes.welcome});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    const colors = ThemeColors.light;
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: AppColors.primary,
        fontFamily: AppFonts.sans,
        scaffoldBackgroundColor: colors.background,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.ink,
          contentTextStyle: AppFonts.body(14, Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: colors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: child!,
      ),
      initialRoute: initialRoute,
      routes: {
        Routes.welcome: (_) => const WelcomeScreen(),
        Routes.register: (_) => const RegisterScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.tabs: (_) => const BottomTabScreen(),
      },
    );
  }
}
