import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';

class UserLevelBadge extends ConsumerWidget {
  const UserLevelBadge({super.key});

  // Método auxiliar para traducir el String del modelo a un Color de Flutter
  Color _getBadgeColor(String statusColor) {
    switch (statusColor) {
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "teal":
        return Colors.teal;
      case "orange":
        return Colors.orange;
      case "red":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el perfil completo (LifestyleProfile)
    final financeAsync = ref.watch(financeLogicProvider);

    return financeAsync.maybeWhen(
      data: (engine) {
        // Obtenemos el perfil directo del engine
        final profile = engine.getLifestyleLevel();
        final color = _getBadgeColor(profile.statusColor);

        // Usamos ActionChip para que sea clickeable
        return ActionChip(
          label: Text(
            profile.name,
            style: TextStyle(
              color: color.withValues(
                alpha: 0.9,
              ), // Ajustado para Flutter > 3.22
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: color.withValues(alpha: 0.1),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          onPressed: () {
            // Aprovechamos los nuevos campos para darle retroalimentación al usuario
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.insights, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(profile.name, style: TextStyle(color: color)),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.message,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(profile.advice, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          },
        );
      },
      orElse: () => const SizedBox.shrink(), // Oculto mientras carga
    );
  }
}
