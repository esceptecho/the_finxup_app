import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/models/life_style_profile.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

// --- MODELOS AUXILIARES PARA UI/UX ---
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

// --- PROVIDER COMBINADO Y REACTIVO ---
/// Este provider reacciona automáticamente si las transacciones, metas o facturas cambian.
/// Maneja correctamente los estados de carga y error.
final financeLogicProvider = Provider<AsyncValue<FinanceAnalyticsEngine>>((
  ref,
) {
  final txsAsync = ref.watch(transactionListNotifierProvider);
  final billsAsync = ref.watch(billListNotifierProvider);
  final goalsAsync = ref.watch(goalListNotifierProvider);

  // Si alguno está cargando, retornamos loading
  if (txsAsync.isLoading || billsAsync.isLoading || goalsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  // Si alguno tiene error, lo propagamos de forma segura
  if (txsAsync.hasError) {
    return AsyncValue.error(txsAsync.error!, txsAsync.stackTrace!);
  }
  if (billsAsync.hasError) {
    return AsyncValue.error(billsAsync.error!, billsAsync.stackTrace!);
  }
  if (goalsAsync.hasError) {
    return AsyncValue.error(goalsAsync.error!, goalsAsync.stackTrace!);
  }

  // Construimos el motor con los datos asegurados (con fallbacks a listas vacías por precaución)
  return AsyncValue.data(
    FinanceAnalyticsEngine(
      transactions: txsAsync.value ?? [],
      bills: billsAsync.value ?? [],
      goals: goalsAsync.value ?? [],
    ),
  );
});

// --- MOTOR ANALÍTICO CENTRAL ---
/// Clase inmutable que agrupa toda la lógica de negocio y cálculos financieros.
class FinanceAnalyticsEngine {
  final List<Transaction> transactions;
  final List<Bill> bills;
  final List<Goal> goals;

  FinanceAnalyticsEngine({
    required this.transactions,
    required this.bills,
    required this.goals,
  });

  // --- 1. ÍNDICE DE SALUD FINANCIERA (Algoritmo Optimizado) ---
  double getFinancialHealthIndex() {
    final positiveExpenseCategories = {
      ExpenseSubCategory.savings,
      ExpenseSubCategory.education,
      ExpenseSubCategory.insurance,
    };

    final positiveIncomeCategories = {IncomeSubCategory.investment};

    final lifestyleCategories = {
      ExpenseSubCategory.leisure,
      ExpenseSubCategory.entertainment,
      ExpenseSubCategory.coffee,
      ExpenseSubCategory.snacks,
      ExpenseSubCategory.delivery,
      ExpenseSubCategory.shopping,
      ExpenseSubCategory.travel,
    };

    double positiveHabits = 0.0;
    double criticalNegativeSpend = 0.0;
    double totalLifestyleSpend = 0.0;

    // Bucle único para máxima eficiencia
    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        if (positiveIncomeCategories.contains(t.subCategory)) {
          positiveHabits += t.amount;
        }
      } else if (t.type == TransactionType.expense) {
        if (positiveExpenseCategories.contains(t.subCategory)) {
          positiveHabits += t.amount;
        } else if (lifestyleCategories.contains(t.subCategory)) {
          totalLifestyleSpend += t.amount;
        } else if (t.subCategory == ExpenseSubCategory.impulsive ||
            t.subCategory == ExpenseSubCategory.interest ||
            t.subCategory == ExpenseSubCategory.subscription) {
          criticalNegativeSpend += t.amount;
        }
      }
    }

    double lifestylePenalty = totalLifestyleSpend;
    if (totalLifestyleSpend > 150.0) {
      double excess = totalLifestyleSpend - 150.0;
      lifestylePenalty += excess * 1.5;
    }

    double totalNegativeHabits = criticalNegativeSpend + lifestylePenalty;
    return (3 * positiveHabits) - (4 * totalNegativeHabits);
  }

  // --- 2. TERMÓMETRO FINANCIERO AVANZADO ---
  HealthStatusProfile getHealthStatusProfile() {
    final score = getFinancialHealthIndex();
    if (score >= 500) {
      return HealthStatusProfile(
        label: "Salud Excelente ¡Sigue así!",
        icon: Icons.workspace_premium_rounded,
        badgeColor: Colors.greenAccent,
      );
    } else if (score >= 0) {
      return HealthStatusProfile(
        label: "Hábito Estable y Balanceado",
        icon: Icons.trending_up_rounded,
        badgeColor: Colors.tealAccent,
      );
    } else if (score >= -300) {
      return HealthStatusProfile(
        label: "Advertencia: Recorta gastos hormiga",
        icon: Icons.report_problem_rounded,
        badgeColor: Colors.orangeAccent,
      );
    } else {
      return HealthStatusProfile(
        label: "Alerta Crítica: Revisa tu presupuesto",
        icon: Icons.gavel_rounded,
        badgeColor: Colors.redAccent,
      );
    }
  }

  // --- 3. NIVEL DE ESTILO DE VIDA ---
  LifestyleProfile getLifestyleLevel() {
    final lifestyleCategories = {
      ExpenseSubCategory.leisure,
      ExpenseSubCategory.entertainment,
      ExpenseSubCategory.coffee,
      ExpenseSubCategory.snacks,
      ExpenseSubCategory.delivery,
      ExpenseSubCategory.travel,
      ExpenseSubCategory.shopping,
    };

    double funSpend = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              lifestyleCategories.contains(t.subCategory),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    if (funSpend <= 50) {
      return LifestyleProfile(
        name: "Monje Financiero",
        message: "Tu nivel de gasto en ocio es casi inexistente.",
        advice:
            "¡Excelente capacidad de ahorro! Pero recuerda disfrutar de vez en cuando.",
        statusColor: "blue",
      );
    } else if (funSpend <= 150) {
      return LifestyleProfile(
        name: "Ahorrador Consciente",
        message: "Mantienes tus antojos y salidas bajo un control estricto.",
        advice: "Estás priorizando tu futuro sin privación extrema. Sigue así.",
        statusColor: "green",
      );
    } else if (funSpend <= 350) {
      return LifestyleProfile(
        name: "Estilo de Vida Balanceado",
        message:
            "Disfrutas de la vida, el café y las salidas de forma moderada.",
        advice:
            "Tienes un equilibrio sano. Asegura que tu ahorro mensual sea igual o superior.",
        statusColor: "teal",
      );
    } else if (funSpend <= 600) {
      return LifestyleProfile(
        name: "Explorador del Confort",
        message:
            "El delivery, las compras y el entretenimiento cobran protagonismo.",
        advice:
            "Ojo con los gastos hormiga. Recorta un 15% en snacks y tu cuenta lo agradecerá.",
        statusColor: "orange",
      );
    } else {
      return LifestyleProfile(
        name: "Vividor (Alerta Roja)",
        message: "Estás viviendo al límite o dándote una vida de rockstar.",
        advice:
            "¡Frena el coche! Estás destinando demasiado a la gratificación instantánea.",
        statusColor: "red",
      );
    }
  }

  // --- 4. GASTOS ONLINE EXTRANJEROS (Composición) ---
  double calculateForeignOnlineSpend(double usdAmount, double exchangeRate) {
    double toLocal(double amount) => amount * exchangeRate;
    double applyBankFee(double amount) => amount * 1.03;
    return applyBankFee(toLocal(usdAmount));
  }

  // --- 5. TENDENCIA DE GASTO EN COMIDA ---
  String getFoodSpendingTrend() {
    final now = DateTime.now();

    double thisMonthFood = transactions
        .where(
          (t) =>
              t.subCategory == ExpenseSubCategory.food &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    double lastMonthFood = transactions
        .where(
          (t) =>
              t.subCategory == ExpenseSubCategory.food &&
              t.date.month == now.month - 1,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    if (thisMonthFood > lastMonthFood) return "Creciente 📈";
    if (thisMonthFood < lastMonthFood) return "Decreciente 📉";
    return "Estable ➖";
  }

  // --- 6. PROYECCIÓN DE LIQUIDEZ (Cuadrática con Bills integrados) ---
  double predictDaysOfLiquidity() {
    double totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);

    double totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    double balance = totalIncome - totalExpense;

    // Gasto lineal fijo diario extraído de las facturas
    double monthlyBills = bills.fold(0.0, (s, b) => s + b.amount);
    double b = monthlyBills > 0 ? -monthlyBills / 30 : -50.0;
    double a = -1.5;

    double discriminant = pow(b, 2) - (4 * a * balance);
    if (discriminant < 0 || balance <= 0) return 0;

    return (-b - sqrt(discriminant)) / (2 * a);
  }

  // --- 7. VIABILIDAD DE METAS ---
  List<String> checkGoalsViability() {
    List<String> alerts = [];
    for (var goal in goals) {
      if (goal.currentAmount < (goal.targetAmount * 0.2)) {
        alerts.add(
          "Tu meta '${goal.title}' está por debajo del 20% del mínimo recomendado.",
        );
      }
    }
    return alerts;
  }

  // --- 8. LÍMITE SEGURO DE GASTO ---
  bool isSafeSpend(double newExpenseAmount) {
    double totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    return newExpenseAmount > 0 && newExpenseAmount <= (totalIncome * 0.5);
  }

  // --- 9. GASTO PROMEDIO HISTÓRICO ---
  double getAverageMonthlyExpense(
    ExpenseSubCategory subCategory, {
    int months = 3,
  }) {
    final now = DateTime.now();
    final cutoffDate = DateTime(now.year, now.month - months + 1, 1);

    final totalInPeriod = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.subCategory == subCategory &&
              t.date.isAfter(cutoffDate),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final monthsWithData = months.clamp(1, 12);
    return totalInPeriod / monthsWithData;
  }

  // --- 10. GASTO TOTAL POR CATEGORÍA ---
  double getTotalExpenseByCategory(ExpenseSubCategory subCategory) {
    return transactions
        .where(
          (t) =>
              t.type == TransactionType.expense && t.subCategory == subCategory,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
