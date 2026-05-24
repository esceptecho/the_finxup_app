import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final shemeColor = Theme.of(context).colorScheme;
    return Scaffold(
      // Evita que el teclado empuje la imagen de fondo
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Lottie.asset(
                  "assets/lotties/loggin_areesie.json",
                  onLoaded: (composition) {
                    // Ajustamos la duración del controlador a la de la animación
                  },
                  repeat: false,
                ),
                SizedBox(height: 20),
                const Text(
                  'Bienvenido a Finzup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 50),
                _buildTextField(
                  hint: 'Correo electrónico',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hint: 'Contraseña',
                  icon: Icons.lock_outline,
                  isObscure: true,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeHSL.primary,
                      foregroundColor: AppThemeHSL.backgroundDeep,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(
                        'isLoggedIn',
                        true,
                      ); // Guarda que el usuario está logeado
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/onboarding');
                    },
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppThemeHSL.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de texto
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isObscure = false,
    String isEmail = 'Correo electrónico',
  }) {
    return TextField(
      keyboardType: isEmail == hint ? TextInputType.emailAddress: TextInputType.visiblePassword,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:  TextStyle(color: AppThemeHSL.surfaceLighter.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: AppThemeHSL.primary),
        filled: true,
        fillColor: AppThemeHSL.textPrimary, // Transparencia elegante
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
