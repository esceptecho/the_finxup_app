import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_finxup_app/screens/splash_screen.dart';

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    // Obtiene el estado de login. Por defecto, asumimos que no está logeado.
    bool userLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (userLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home'); // '/onboarding'
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    } 
  }

  @override
  Widget build(BuildContext context) {
    // La pantalla de splash real
    return SafeArea(child: SplashScreen());
  }
}