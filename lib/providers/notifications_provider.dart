import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/notification_model.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';
// Asegúrate de cambiar esta importación al archivo donde guardaste el nuevo provider
import 'package:the_finxup_app/providers/goal_prediction_provider.dart';

// Este provider "escucha" los cambios en financeLogicProvider
final notificationlertsProvider = Provider<List<NotificationModel>>((ref) {
  // 1. Observamos el motor analítico completo de forma asíncrona
  final financeAsync = ref.watch(financeLogicProvider);

  // 2. Cambiamos ref.read por ref.watch para que el provider de alertas también
  // se reactive si las predicciones de metas cambian.
  final predictions = ref.watch(goalPredictionProvider);

  // Desenvolvemos el AsyncValue usando el método formal de Riverpod
  return financeAsync.maybeWhen(
    data: (engine) {
      // Si el motor no tiene transacciones cargadas, no hay notificaciones
      if (engine.transactions.isEmpty) return [];

      List<NotificationModel> notifications = [];

      // --- APLICACIÓN MAT-142: Ecuaciones Cuadráticas ---
      // Los métodos matemáticos se llaman directamente desde la instancia 'engine'
      final daysLeft = engine.predictDaysOfLiquidity();
      if (daysLeft > 0 && daysLeft < 15) {
        notifications.add(
          NotificationModel(
            title: "Alerta de Liquidez",
            message:
                "Aceleración de gastos detectada. Tu saldo podría llegar a cero en ${daysLeft.toStringAsFixed(0)} días.",
            icon: Icons.timer_off,
            color: Colors.red,
          ),
        );
      }

      // --- APLICACIÓN MAT-142: Evaluación de Funciones ---
      final healthScore = engine.getFinancialHealthIndex();
      if (healthScore > 1000) {
        notifications.add(
          NotificationModel(
            title: "¡Salud Financiera Óptima!",
            message:
                "La evaluación de tus hábitos (3f - 4g) muestra un crecimiento excelente.",
            icon: Icons.emoji_events,
            color: Colors.green,
          ),
        );
      } else if (healthScore < 0) {
        notifications.add(
          NotificationModel(
            title: "Riesgo Financiero",
            message:
                "Tus deudas o gastos impulsivos están superando tus ahorros.",
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
        );
      }

      // --- APLICACIÓN MAT-142: Intervalos de Crecimiento ---
      final foodTrend = engine.getFoodSpendingTrend();
      if (foodTrend.contains("Creciente")) {
        notifications.add(
          NotificationModel(
            title: "Tendencia de Gasto en Comida",
            message:
                "Tus gastos en alimentación están en un intervalo creciente respecto al mes pasado.",
            icon: Icons.restaurant_menu,
            color: Colors.purple,
          ),
        );
      }

      // --- PROYECCIÓN DE METAS ---
      for (final pred in predictions) {
        if (pred.monthsNeeded <= 3) {
          notifications.add(
            NotificationModel(
              title: '🎯 Meta al alcance',
              message: pred.message,
              icon: Icons.flag,
              color: Colors.blueAccent,
            ),
          );
          break; // Una sola notificación para no saturar la UI
        }
      }

      return notifications;
    },
    // Si el provider financiero está cargando o cae en error,
    // evitamos romper la UI devolviendo una lista vacía temporalmente.
    orElse: () => [],
  );
});
