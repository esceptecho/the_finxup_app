import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';
// import 'package:the_finxup_app/providers/notification_provider.dart';
import 'package:the_finxup_app/providers/notifications_provider.dart';
import 'package:the_finxup_app/screens/goal_prediction_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class FinancialHealthDashboard extends ConsumerWidget {
  const FinancialHealthDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado y el notifier
    final financeAsync = ref.watch(financeLogicProvider);
    final alerts = ref.watch(notificationlertsProvider);

    return financeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error al cargar analíticas')),
      data: (engine) {
        if (engine.transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "Aún no hay datos para calcular tu salud financiera.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthScoreCard(
                // calculatedBalance
                engine.getFinancialHealthIndex(),
              ),
              const SizedBox(height: 20),
              _buildLiquidityCard(engine.predictDaysOfLiquidity()),
              const SizedBox(height: 20),
              const Text(
                "Alertas y Sugerencias",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...alerts.map(
                (notification) => _buildNotificationTile(notification, context),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalPredictionsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Ver más...',
                  style: TextStyle(color: AppThemeHSL.textHint),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildHealthScoreCard(double calculatedBalance) {
    final bool isPositive = calculatedBalance > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [AppThemeHSL.incomeDark, AppThemeHSL.income]
              : [AppThemeHSL.expenseLight, AppThemeHSL.expense],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            "Índice de Salud Financiera",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            calculatedBalance.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isPositive ? "¡Buen balance!" : "Necesitas ajustar gastos",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidityCard(double days) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.speed,
          color: days < 15 ? Colors.red : Colors.cyanAccent,
        ),
        title: const Text("Días de Liquidez Restantes"),
        subtitle: Text("Basado en tu aceleración de gasto actual"),
        trailing: Text(
          "${days.toStringAsFixed(0)} días",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: days < 15 ? Colors.red : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(dynamic notification, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(notification.icon, color: notification.color),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification.message),
      ),
    );
  }
}
