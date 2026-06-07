import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/models/notification_model.dart';
import 'package:the_finxup_app/providers/ds_final_finance_analytics_engine.dart';
import 'package:the_finxup_app/providers/goal_prediction_provider.dart';

// Proveedor de alertas reactivo que escucha el motor financiero mejorado
final notificationAlertsProvider = Provider<List<NotificationModel>>((ref) {
  final financeAsync = ref.watch(dsFinanceLogicProvider);
  final predictions = ref.watch(goalPredictionProvider);

  return financeAsync.maybeWhen(
    data: (engine) {
      if (engine.transactions.isEmpty) return [];

      final notifications = <NotificationModel>[];

      // ----- 1. ALERTA DE LIQUIDEZ (ecuación cuadrática) -----
      final daysLeft = engine.predictDaysOfLiquidity();
      if (daysLeft > 0 && daysLeft < 15) {
        notifications.add(
          NotificationModel(
            title: "⏳ Alerta de Liquidez",
            message:
                "Tu saldo actual podría agotarse en ${daysLeft.toStringAsFixed(0)} días si mantienes el ritmo de gastos.",
            icon: Icons.timer_off,
            color: Colors.red,
          ),
        );
      }

      // ----- 2. ALERTAS DE SALUD FINANCIERA (usando el perfil mejorado) -----
      final healthProfile = engine.getHealthStatusProfile();
      final healthScore = engine.getFinancialHealthIndex();

      if (healthProfile.label.contains("Alerta Crítica")) {
        notifications.add(
          NotificationModel(
            title: "🚨 Crisis Financiera Detectada",
            message: healthProfile.description.length > 100
                ? "${healthProfile.description.substring(0, 100)}..."
                : healthProfile.description,
            icon: Icons.gavel_rounded,
            color: Colors.redAccent,
          ),
        );
      } else if (healthProfile.label.contains("Advertencia")) {
        notifications.add(
          NotificationModel(
            title: "⚠️ Atención: Gastos Hormiga",
            message: healthProfile.description,
            icon: Icons.report_problem_rounded,
            color: Colors.orange,
          ),
        );
      } else if (healthScore > 1000) {
        notifications.add(
          NotificationModel(
            title: "🏆 Salud Financiera Óptima",
            message:
                "Tu índice supera los 1000 puntos. ¡Sigue así! Revisa el desglose para mantenerlo.",
            icon: Icons.emoji_events,
            color: Colors.green,
          ),
        );
      }

      // ----- 3. ALERTAS DE ESTILO DE VIDA (gastos en ocio) -----
      final lifestyle = engine.getLifestyleLevel(includeLottie: false);
      if (lifestyle.name == "Vividor (Alerta Roja)") {
        notifications.add(
          NotificationModel(
            title: "🎭 Estilo de Vida Insostenible",
            message: lifestyle.description,
            icon: Icons.local_fire_department,
            color: Colors.deepOrange,
          ),
        );
      } else if (lifestyle.name == "Explorador del Confort") {
        notifications.add(
          NotificationModel(
            title: "🍕 Gasto Hormiga en Aumento",
            message: lifestyle.description,
            icon: Icons.shopping_cart,
            color: Colors.orangeAccent,
          ),
        );
      }

      // ----- 4. TENDENCIA DE GASTO EN COMIDA -----
      final foodTrend = engine.getFoodSpendingTrend();
      if (foodTrend.contains("Creciente")) {
        final avgFood = engine.getAverageMonthlyExpense(
          ExpenseSubCategory.food,
          months: 3,
        );
        notifications.add(
          NotificationModel(
            title: "📈 Tendencia al Alza en Alimentos",
            message:
                "Tu gasto en comida viene aumentando. Promedio actual: \$${avgFood.toStringAsFixed(2)}. Revisa tus hábitos.",
            icon: Icons.restaurant_menu,
            color: Colors.purple,
          ),
        );
      }

      // ----- 5. VIABILIDAD DE METAS (si están por debajo del 20%) -----
      final goalsAlerts = engine.checkGoalsViability();
      if (goalsAlerts.isNotEmpty) {
        // Tomamos la primera alerta para no saturar, o podemos agregar múltiples
        notifications.add(
          NotificationModel(
            title: "🎯 Meta en Riesgo",
            message: goalsAlerts.first,
            icon: Icons.flag,
            color: Colors.blueAccent,
          ),
        );
      }

      // ----- 6. PROYECCIÓN DE METAS (del provider externo) -----
      for (final pred in predictions) {
        if (pred.monthsNeeded <= 3) {
          notifications.add(
            NotificationModel(
              title: '🎉 Meta al Alcance',
              message: pred.message,
              icon: Icons.flag,
              color: Colors.greenAccent,
            ),
          );
          break; // Una notificación es suficiente
        }
      }

      return notifications;
    },
    orElse: () => [],
  );
});
