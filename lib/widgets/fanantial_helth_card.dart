import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';
import 'package:the_finxup_app/providers/finance_logic_provider.dart';

class FinancialHealthCard extends ConsumerWidget {
  const FinancialHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeLogicProvider);

    return financeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No se pudo calcular el estado financiero.'),
        ),
      ),
      data: (engine) {
        // 1. Extraemos el perfil visual y el puntaje numérico
        final health = engine.getHealthStatusProfile();
        final score = engine.getFinancialHealthIndex();

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Creamos un fondo con un degradado sutil usando el color del badge
              gradient: LinearGradient(
                colors: [health.badgeColor.withOpacity(0.15), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // 2. Icono dinámico dentro de un contenedor circular estilizado
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: health.badgeColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    health.icon,
                    color: health.badgeColor == Colors.greenAccent
                        ? Colors.green[800]
                        : health
                              .badgeColor, // Ajuste para legibilidad si es muy claro
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // 3. Textos informativos dinámicos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        health.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Índice de Salud: ${score.toStringAsFixed(0)} pts",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Un indicador visual extra o flecha por si quieren ver el desglose
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
        );
      },
    );
  }
}
