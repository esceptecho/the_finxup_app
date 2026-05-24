import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

class GoalPrediction {
  final String goalName;
  final String category; // ej: 'Café', 'Suscripciones'
  final double monthlyExpense; // €/mes que se gasta en esa categoría
  final int monthsNeeded; // meses para alcanzar la meta

  GoalPrediction({
    required this.goalName,
    required this.category,
    required this.monthlyExpense,
    required this.monthsNeeded,
  });

  // Getter en lugar de campo
  String get message {
    if (monthsNeeded <= 0) {
      return '¡Ya tienes suficiente para "$goalName" si rediriges ese gasto!';
    }
    return 'Si dejas de gastar ${monthlyExpense.toStringAsFixed(0)} €/mes en $category, alcanzarás "$goalName" en $monthsNeeded meses.';
  }
}

final goalPredictionProvider = Provider<List<GoalPrediction>>((ref) {
  // 1. Escuchamos el provider que REALMENTE tiene las transacciones de Hive
  final transactionsAsync = ref.watch(transactionListNotifierProvider);
  final transactions = transactionsAsync.value ?? [];

  // 2. Escuchamos las metas
  final goalsAsync = ref.watch(goalListNotifierProvider);
  final goals = goalsAsync.value ?? [];

  print('--- Debug Predicciones ---');
  print('Transacciones totales: ${transactions.length}');
  print('Metas encontradas: ${goals.length}');

  if (transactions.isEmpty || goals.isEmpty) return [];

  if (transactions.isEmpty || goals.isEmpty) return [];

  final cuttableCategories = {
    ExpenseSubCategory.clothing,
    ExpenseSubCategory.coffee,
    ExpenseSubCategory.delivery,
    ExpenseSubCategory.entertainment,
    ExpenseSubCategory.gifts,
    ExpenseSubCategory.impulsive,
    ExpenseSubCategory.leisure,
    ExpenseSubCategory.online,
    ExpenseSubCategory.shopping,
    ExpenseSubCategory.snacks,
    ExpenseSubCategory.subscription,
  };

  List<GoalPrediction> predictions = [];

  for (final category in cuttableCategories) {
    // Calculamos el promedio directamente aquí para que sea reactivo
    final monthlyExpense = _calculateAverage(transactions, category, 3);

    if (monthlyExpense <= 0) continue;
    if (monthlyExpense > 0) {
      print(
        'Categoría recortable detectada: ${category.name} con gasto de $monthlyExpense',
      );
    }

    for (final goal in goals) {
      final remaining = goal.targetAmount - goal.currentAmount;
      if (remaining <= 0) continue;

      final monthsNeeded = (remaining / monthlyExpense).ceil();

      predictions.add(
        GoalPrediction(
          goalName: goal.title,
          // Usamos .name para evitar que salga "ExpenseSubCategory.coffee"
          category: category.name,
          monthlyExpense: monthlyExpense,
          monthsNeeded: monthsNeeded,
        ),
      );
    }
  }

  // Ordenar por las metas más próximas a cumplirse
  predictions.sort((a, b) => a.monthsNeeded.compareTo(b.monthsNeeded));
  return predictions;
});

// Función auxiliar pura (fuera de la clase si quieres)
double _calculateAverage(
  List<Transaction> transactions,
  ExpenseSubCategory sub,
  int months,
) {
  final now = DateTime.now();
  final cutoffDate = DateTime(now.year, now.month - months + 1, 1);

  final totalInPeriod = transactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.subCategory == sub &&
            t.date.isAfter(cutoffDate),
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  return totalInPeriod / months;
}
