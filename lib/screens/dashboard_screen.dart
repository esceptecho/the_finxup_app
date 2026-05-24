import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/life_style_profile.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';
import 'package:the_finxup_app/providers/old_finance_analytics_engine.dart';
// import 'package:the_finxup_app/providers/finance_logic_provider.dart';
import 'package:the_finxup_app/providers/notification_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/liquidity_chart.dart';
import 'package:the_finxup_app/widgets/notification_tile.dart';

/*
El DashboardScreen se había llenado de "basura visual" porque teníamos elementos duplicados (dos veces el termómetro)
y redundantes (la tarjeta de liquidez mostraba lo mismo que el gráfico, pero con menos estilo).Para tener una 
interfaz "Dark Mode" profesional y minimalista, he reorganizado la pantalla siguiendo esta jerarquía:Gráfico Hero 
(Arriba): La curva de liquidez es lo más importante.Tarjetas de Tendencia (Centro): Pequeñas y elegantes.
Termómetro Dinámico (Abajo): Ahora calculado matemáticamente en base al volumen real del usuario.Notificaciones 
(Final): Solo si es necesario.La Matemática de la Normalización DinámicaPara que el termómetro funcione sin importar
si el usuario maneja $100 o $10,000, calculamos el volumen total de transacciones $V$. Sabiendo que tu función es
$H(x) = 3f - 4g$, el límite inferior teórico es $-4V$ y el superior es $3V$.Aplicamos una transformación lineal
para normalizar el rango al intervalo $[0, 1]$ de la UI:$$N(x) = \frac{H(x) - (-4V)}{3V - (-4V)} = \frac{H(x) + 4V}{7V}$$
 */

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final engineAsync = ref.watch(financeLogicProvider);
    final engineAsync = ref.watch(financeLogicProvider);
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      // Fondo oscuro base de tu app
      backgroundColor: AppThemeHSL.backgroundDeep,
      appBar: AppBar(
        title: const Text(
          'Resumen Financiero',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: engineAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
        error: (err, stack) => Center(
          child: Text(
            "Error: $err",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (engine) {
          if (engine.transactions.isEmpty) {
            return _buildEmptyState();
          }

          // Cálculos MAT-142
          final healthScore = engine.getFinancialHealthIndex();
          final userLevel = engine.getLifestyleLevel();
          final foodTrend = engine.getFoodSpendingTrend();

          // Variable V: Volumen total para el termómetro dinámico
          final totalVolume = engine.transactions.fold(
            0.0,
            (sum, t) => sum + t.amount.abs(),
          );

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children: [
              // 1. El gráfico principal (LiquidityChart ya está en modo oscuro)
              LiquidityChart(engine: engine),
              const SizedBox(height: 20),

              // 2. Tarjetas pequeñas de análisis (Funciones a Trozos / Intervalos)
              _buildInsightsGrid(userLevel, foodTrend),
              const SizedBox(height: 20),

              // 3. Termómetro con normalización dinámica
              _buildHealthIndexGauge(healthScore, totalVolume),
              const SizedBox(height: 32),

              // 4. Sección de Notificaciones
              const Text(
                "Insights & Alertas",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              if (notifications.isEmpty)
                Text(
                  "✅ Todo bajo control por ahora. Buen trabajo.",
                  style: TextStyle(color: Colors.blueGrey.shade300),
                )
              else
                ...notifications.map(
                  (notif) => NotificationTile(notification: notif),
                ),

              const SizedBox(height: 30), // Margen inferior
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES ADAPTADOS A MODO OSCURO ---

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.blueGrey.shade700,
            ),
            const SizedBox(height: 16),
            const Text(
              "Aún no tienes movimientos.\n¡Añade tu primer ingreso!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsGrid(LifestyleProfile userLevel, String foodTrend) {
    // Convertimos el String del color del perfil en un Color real de Flutter
    Color getProfileColor(String colorName) {
      switch (colorName) {
        case 'blue':
          return Colors.blueAccent;
        case 'green':
          return Colors.greenAccent;
        case 'teal':
          return Colors.tealAccent;
        case 'orange':
          return Colors.orangeAccent;
        case 'red':
          return Colors.redAccent;
        default:
          return const Color(0xFF9D4EDD); // Tu Morado Neón por defecto
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            title: "Perfil",
            value: userLevel
                .name, // 👈 Ahora extraemos el .name ("Monje", "Vividor", etc.)
            icon: Icons.person_outline,
            color: getProfileColor(
              userLevel.statusColor,
            ), // 👈 ¡UX mejorada con color dinámico!
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMiniCard(
            title: "Comida",
            value: foodTrend,
            icon: Icons.restaurant_menu,
            color: const Color(0xFF00F2FE), // Cian Neón
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E), // Fondo oscuro de tarjeta
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndexGauge(double score, double totalVolume) {
    // Normalización Dinámica MAT-142 (Dominio adaptativo)
    double normalizedScore;
    if (totalVolume == 0) {
      normalizedScore = 0.5; // Neutral si no hay movimientos reales
    } else {
      double maxPossible = totalVolume * 3;
      double minPossible = totalVolume * -4;
      normalizedScore = (score - minPossible) / (maxPossible - minPossible);
      normalizedScore = normalizedScore.clamp(0.0, 1.0);
    }

    // Colores para Dark Mode
    Color scoreColor = score > 0
        ? const Color(0xFF00E676)
        : const Color(0xFFFF1744); // Verde Neón o Rojo Neón
    String status = score > 0 ? "Sano" : "Riesgo";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E), // Mismo tono que el chart
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Termómetro Financiero",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 110,
                width: 110,
                child: CircularProgressIndicator(
                  value: normalizedScore,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withValues(
                    alpha: 0.05,
                  ), // Pista oscura
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pts: ${score.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
