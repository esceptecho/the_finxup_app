import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/screens/user_level_badge.dart';

// Asegúrate de importar el archivo donde guardaste UserLevelBadge
// import 'package:the_finxup_app/widgets/user_level_badge.dart';

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      // margin: const EdgeInsets.all(16),
      elevation: 2, // Le damos un poco de profundidad
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bordes más suaves
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Un poco más de respiro interno
        child: Row(
          children: [
            // Mejoramos estéticamente el avatar
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.show_chart_outlined,
                size: 40,
                color: Colors.white60,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "¡Hola, Arees!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 🔥 Instanciamos nuestro widget limpio sin duplicar código
                  const UserLevelBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
