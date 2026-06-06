import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/ds_life_style_profile.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/models/life_style_profile.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

// --- PROVIDER COMBINADO Y REACTIVO ---
/// Este provider reacciona automáticamente si las transacciones, metas o facturas cambian.
/// Maneja correctamente los estados de carga y error.
final dsFinanceLogicProvider = Provider<AsyncValue<FinanceAnalyticsEngine>>((
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
  /// Calcula un índice de salud financiera más robusto.
  /// Rangos típicos: [-1000, +1000] -> cuanto más alto, mejor.
  double getFinancialHealthIndex() {
    // Categorías positivas (ahorro, educación, seguros, ingresos extra)
    const positiveCategories = {
      ExpenseSubCategory.savings,
      ExpenseSubCategory.education,
      ExpenseSubCategory.insurance,
      IncomeSubCategory.bonus,
      IncomeSubCategory.freelance,
      IncomeSubCategory.investment,
      IncomeSubCategory.dividend,
      IncomeSubCategory.interest,
      IncomeSubCategory.rental,
    };

    // Categorías negativas críticas (deuda, intereses, suscripciones innecesarias)
    const criticalNegative = {
      ExpenseSubCategory.interest,
      ExpenseSubCategory.subscription, // si no es esencial
    };

    double positiveScore = 0.0;
    double negativeScore = 0.0;
    double lifestyleSpend = 0.0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        if (positiveCategories.contains(t.subCategory)) {
          positiveScore += t.amount * 1.5; // peso extra a ingresos no-salario
        } else {
          positiveScore += t.amount * 0.5; // salario base tiene menor peso
        }
      } else {
        // expense
        if (positiveCategories.contains(t.subCategory)) {
          positiveScore +=
              t.amount; // ahorro/educación/seguro cuentan como positivo
        } else if (criticalNegative.contains(t.subCategory)) {
          negativeScore += t.amount * 2.0; // deuda e intereses penalizan doble
        } else if (_isLifestyleCategory(t.subCategory)) {
          lifestyleSpend += t.amount;
        } else {
          negativeScore += t.amount * 0.5; // gasto necesario pero no crítico
        }
      }
    }

    // Penalización por gasto hormiga (lifestyle) con umbral suave
    double lifestylePenalty = lifestyleSpend;
    if (lifestyleSpend > 150) {
      lifestylePenalty += (lifestyleSpend - 150) * 1.2;
    }

    double totalNegative = negativeScore + lifestylePenalty;
    double rawScore = positiveScore - totalNegative;

    // Normalización para que el rango sea más intuitivo (escala ~ -1000 a +1000)
    return rawScore.clamp(-1000.0, 1000.0);
  }

  // --- 2. TERMÓMETRO FINANCIERO AVANZADO ---
  NewHealthStatusProfile getHealthStatusProfile() {
    final score = getFinancialHealthIndex();

    if (score >= 500) {
      return NewHealthStatusProfile(
        label: "Salud Excelente ¡Sigue así!",
        icon: Icons.workspace_premium_rounded,
        badgeColor: Colors.greenAccent,
        description:
            "Tu índice financiero es $score (máximo 1000). "
            "Tienes altos ingresos no salariales o ahorros consistentes, "
            "muy pocas deudas y un control excelente del gasto hormiga.",
      );
    } else if (score >= 0) {
      return NewHealthStatusProfile(
        label: "Hábito Estable y Balanceado",
        icon: Icons.trending_up_rounded,
        badgeColor: Colors.tealAccent,
        description:
            "Tu puntuación ($score) indica que estás en el rango saludable. "
            "No hay alarmas, pero podrías optimizar un poco más el ahorro o reducir "
            "gastos superfluos para alcanzar la excelencia.",
      );
    } else if (score >= -300) {
      return NewHealthStatusProfile(
        label: "Advertencia: Recorta gastos hormiga",
        icon: Icons.report_problem_rounded,
        badgeColor: Colors.orangeAccent,
        description:
            "Tu índice ($score) está en zona de atención. "
            "El problema principal suele ser el exceso de gastos pequeños (cafés, delivery, compras impulsivas). "
            "Reduce un 15% de ellos y volverás a zona verde.",
      );
    } else {
      return NewHealthStatusProfile(
        label: "Alerta Crítica: Revisa tu presupuesto",
        icon: Icons.gavel_rounded,
        badgeColor: Colors.redAccent,
        description:
            "Tu puntuación ($score) está muy por debajo de lo recomendado. "
            "Posibles causas: deudas altas, ingresos insuficientes o descontrol total de gastos. "
            "Necesitas un plan urgente de reestructuración financiera.",
      );
    }
  }

  // --- 3. NIVEL DE ESTILO DE VIDA ---
  /// Devuelve el perfil de estilo de vida basado en gastos de ocio y caprichos.
  /// [includeLottie] si es true, asigna animaciones Lottie.
  NewLifestyleProfile getLifestyleLevel({bool includeLottie = false}) {
    final funSpend = _calculateFunSpend();

    // Definiciones de perfiles con sus umbrales y descripciones
    if (funSpend <= 50) {
      return NewLifestyleProfile(
        name: "Monje Financiero",
        message: "Tu nivel de gasto en ocio es casi inexistente.",
        advice:
            "¡Excelente capacidad de ahorro! Pero recuerda disfrutar de vez en cuando.",
        statusColor: "blue",
        description:
            "Gastaste solo \$${funSpend.toStringAsFixed(2)} en ocio este mes "
            "(máximo recomendado para este perfil: \$50). Esto indica una disciplina extrema, "
            "ideal para ahorrar, pero cuidado con la privación excesiva.",
        lottieAsset: includeLottie ? "assets/lotties/Fireworks.json" : null,
        loopLottie: true,
        lottieHeight: 150,
      );
    } else if (funSpend <= 150) {
      return NewLifestyleProfile(
        name: "Ahorrador Consciente",
        message: "Mantienes tus antojos y salidas bajo un control estricto.",
        advice: "Estás priorizando tu futuro sin privación extrema. Sigue así.",
        statusColor: "green",
        description:
            "Tus gastos de ocio (\$${funSpend.toStringAsFixed(2)}) están dentro del "
            "rango saludable (hasta \$150). Disfrutas sin poner en riesgo tus metas.",
        lottieAsset: includeLottie
            ? "assets/lotties/Man_flyingairplane.json"
            : null,
        loopLottie: true,
        lottieHeight: 150,
      );
    } else if (funSpend <= 350) {
      return NewLifestyleProfile(
        name: "Estilo de Vida Balanceado",
        message:
            "Disfrutas de la vida, el café y las salidas de forma moderada.",
        advice:
            "Tienes un equilibrio sano. Asegura que tu ahorro mensual sea igual o superior.",
        statusColor: "teal",
        description:
            "Gastaste \$${funSpend.toStringAsFixed(2)} en ocio (rango: \$151-350). "
            "Es un nivel normal, pero revisa que no esté comiendo tu capacidad de ahorro.",
        lottieAsset: includeLottie
            ? "assets/lotties/Financial_charts_statistics.json"
            : null,
        loopLottie: false,
        lottieHeight: 150,
      );
    } else if (funSpend <= 600) {
      return NewLifestyleProfile(
        name: "Explorador del Confort",
        message:
            "El delivery, las compras y el entretenimiento cobran protagonismo.",
        advice:
            "Ojo con los gastos hormiga. Recorta un 15% en snacks y tu cuenta lo agradecerá.",
        statusColor: "orange",
        description:
            "Has destinado \$${funSpend.toStringAsFixed(2)} a ocio este mes "
            "(rango \$351-600). Estás rozando el límite de lo saludable; un ajuste menor "
            "mejorará tu salud financiera.",
        lottieAsset: includeLottie ? "assets/lotties/wallet.json" : null,
        loopLottie: false,
        lottieHeight: 150,
      );
    } else {
      return NewLifestyleProfile(
        name: "Vividor (Alerta Roja)",
        message: "Estás viviendo al límite o dándote una vida de rockstar.",
        advice:
            "¡Frena el coche! Estás destinando demasiado a la gratificación instantánea.",
        statusColor: "red",
        description:
            "¡Cuidado! Gastaste \$${funSpend.toStringAsFixed(2)} en ocio "
            "(superior a \$600). Este nivel es insostenible a largo plazo y está "
            "hipotecando tu futuro financiero.",
        lottieAsset: includeLottie ? "assets/lotties/warning_pulse.json" : null,
        loopLottie: false,
        lottieHeight: 150,
      );
    }
  }

  /// Genera un texto detallado que explica al usuario por qué está en su perfil actual,
  /// incluyendo cifras concretas de su gasto y consejos personalizados.
  String getProfileExplanation() {
    final healthProfile = getHealthStatusProfile();
    final lifestyleProfile = getLifestyleLevel(includeLottie: false);
    final funSpend = _calculateFunSpend();

    return """
🔍 **ANÁLISIS DETALLADO DE TU PERFIL**

📊 **Salud Financiera:** ${healthProfile.label}
   • Puntuación: ${getFinancialHealthIndex().toStringAsFixed(0)} pts.
   • ${healthProfile.description}

🎭 **Estilo de Vida:** ${lifestyleProfile.name}
   • Gasto en ocio y caprichos: \$${funSpend.toStringAsFixed(2)} este mes.
   • ${lifestyleProfile.description}

💡 **Consejo principal:** ${lifestyleProfile.advice}

✅ **Próximos pasos sugeridos:**
   ${_generateActionPlan()}
""";
  }

  String _generateActionPlan() {
    final score = getFinancialHealthIndex();
    if (score >= 500) {
      return "Mantén tu estrategia actual y considera invertir el excedente.";
    } else if (score >= 0) {
      return "Automatiza un ahorro del 10% de tus ingresos y reduce delivery un 20%.";
    } else {
      return "Haz un seguimiento diario de gastos por 30 días. Elimina suscripciones no usadas.";
    }
  }

  /// Método auxiliar para calcular el gasto total en categorías de estilo de vida
  double _calculateFunSpend() {
    const lifestyleCategories = {
      ExpenseSubCategory.leisure,
      ExpenseSubCategory.entertainment,
      ExpenseSubCategory.coffee,
      ExpenseSubCategory.snacks,
      ExpenseSubCategory.delivery,
      ExpenseSubCategory.travel,
      ExpenseSubCategory.shopping,
      ExpenseSubCategory.gifts,
      ExpenseSubCategory.beauty,
    };

    return transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              lifestyleCategories.contains(t.subCategory),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Verifica si una subcategoría es considerada "lifestyle"
  bool _isLifestyleCategory(ExpenseSubCategory sub) {
    const lifestyle = {
      ExpenseSubCategory.leisure,
      ExpenseSubCategory.entertainment,
      ExpenseSubCategory.coffee,
      ExpenseSubCategory.snacks,
      ExpenseSubCategory.delivery,
      ExpenseSubCategory.travel,
      ExpenseSubCategory.shopping,
      ExpenseSubCategory.gifts,
      ExpenseSubCategory.beauty,
    };
    return lifestyle.contains(sub);
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
