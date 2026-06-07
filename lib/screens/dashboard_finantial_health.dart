import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart'; // <-- Nueva importación para animaciones
import 'package:the_finxup_app/providers/ds_final_finance_analytics_engine.dart';
import 'package:the_finxup_app/providers/notifications_provider.dart';
import 'package:the_finxup_app/screens/dashboard_screen.dart';
import 'package:the_finxup_app/screens/goal_prediction_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DashboardFinancialHealth extends ConsumerWidget {
  const DashboardFinancialHealth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos de forma reactiva tanto el estado como el notifier
    // Escuchamos el motor analítico completo
    final financeAsync = ref.watch(dsFinanceLogicProvider);
    // Cambiado a .watch para reactividad
    final alerts = ref.watch(notificationAlertsProvider);

    // --- UX MEJORADA: Vista del Estado Vacío con Lottie ---
    return financeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (engine) {
        // Ahora accedemos de forma segura a las transacciones dentro del engine
        if (engine.transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Puedes descargar un JSON de billetera vacía de Lottiefiles.com
                  Lottie.asset(
                    'assets/lotties/Financial_charts_statistics.json',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    repeat: false,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Aún no hay datos disponibles",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "Registra tus primeros ingresos o gastos para calcular tu salud financiera.",
                      textAlign:
                          TextAlign.center, // Corregido el error de sintaxis
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Si hay datos, construimos la UI normal usando el engine
        // final healthIndex = engine.getFinancialHealthIndex(); // Parametro para _buildHealthScoreCard
        final liquidityDays = engine.predictDaysOfLiquidity();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de score optimizada
              // _buildHealthScoreCard(healthIndex),
              // FinancialHealthCard(),
              // const SizedBox(height: 20),
              _buildLiquidityCard(liquidityDays, context),
              const SizedBox(height: 24),

              // Encabezado de Alertas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Alertas y Sugerencias",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (alerts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${alerts.length} pendientes',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Listado de Alertas
              if (alerts.isEmpty)
                _buildEmptyAlertsTile()
              else
                ...alerts.map(
                  (notification) =>
                      _buildNotificationTile(notification, context),
                ),

              // const SizedBox(height: 12),

              // Botón de acción mejorado estéticamente
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoalPredictionsScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.analytics_rounded,
                  color: AppThemeHSL.textSecondary,
                  size: 18,
                ),
                label: Text(
                  'Ver proyecciones detalladas',
                  style: TextStyle(
                    color: AppThemeHSL.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  } // FIN BUILD



  Widget _buildLiquidityCard(double days, BuildContext context) {
    final bool isLowLiquidity = days < 15;
    final Color stateColor = isLowLiquidity
        ? Colors.redAccent
        : Colors.tealAccent;

    return Hero(
      tag: '_buildLiquidityCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        },
        child: Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLowLiquidity ? Icons.speed_rounded : Icons.bolt_rounded,
                  color: stateColor,
                  size: 24,
                ),
              ),
              title: const Text(
                "Proyección de Liquidez",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                "Días estimados según tu ritmo de gasto",
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                "${days.toStringAsFixed(0)} días",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: stateColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(dynamic notification, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      elevation: 1,
      child: ListTile(
        leading: Icon(notification.icon, color: notification.color),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          notification.message,
          style: const TextStyle(fontSize: 12),
        ),
        dense: true,
      ),
    );
  }

  Widget _buildEmptyAlertsTile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_moon_rounded, color: Colors.greenAccent, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Todo bajo control. No tienes alertas financieras críticas.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Clase auxiliar para empaquetar la información del estado de salud
class HealthStatusProfile {
  final String label;
  final IconData icon;
  final Color badgeColor;

  HealthStatusProfile({
    required this.label,
    required this.icon,
    required this.badgeColor,
  });
}


