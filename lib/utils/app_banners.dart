// lib/utils/app_banners.dart
import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';

class AppBanners {
  // Ponemos el método aquí adentro
  // MÉTODO GENÉRICO (El que le faltaba a tu error)
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    BannerType type = BannerType.info,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentMaterialBanner();

    scaffoldMessenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: _getBg(type),
        content: Text(message, style: TextStyle(color: _getText(type))),
        actions: [
          TextButton(
            onPressed: () => scaffoldMessenger.hideCurrentMaterialBanner(),
            child: Text('OK', style: TextStyle(color: _getText(type))),
          ),
        ],
      ),
    );
  }
  /// Muestra un banner especial de bienvenida con colores vibrantes
  static void showWelcome(
    BuildContext context, {
    required String userName,
    required String statusSummary,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentMaterialBanner();

    // Determinar saludo por hora
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Buenos días' : (hour < 19 ? 'Buenas tardes' : 'Buenas noches');

    final banner = MaterialBanner(
      elevation: 4, // Un poco de sombra para que resalte al entrar
      backgroundColor: AppThemeHSL.primaryDark.withOpacity(0.95), // Fondo vibrante pero ligeramente translúcido
      dividerColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.waving_hand_rounded, color: Colors.amberAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$greeting, $userName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSummary,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => scaffoldMessenger.hideCurrentMaterialBanner(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Entendido',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    scaffoldMessenger.showMaterialBanner(banner);

    // Se oculta automáticamente después de 5 segundos para que el usuario tenga tiempo de leer
    Future.delayed(const Duration(seconds: 5), () {
      if (context.mounted) scaffoldMessenger.hideCurrentMaterialBanner();
    });
  }
  // Helpers privados para colores
  static Color _getBg(BannerType type) => type == BannerType.success ? Colors.teal[50]! : Colors.blueGrey[50]!;
  static Color _getText(BannerType type) => type == BannerType.success ? Colors.teal[900]! : Colors.blueGrey[900]!;
}