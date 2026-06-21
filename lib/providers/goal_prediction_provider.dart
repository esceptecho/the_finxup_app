import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

class GoalPrediction {
  final String goalName;
  final String category;
  final double monthlyExpense;
  final int monthsNeeded;

  GoalPrediction({
    required this.goalName,
    required this.category,
    required this.monthlyExpense,
    required this.monthsNeeded,
  });

  // Clave única para identificar esta predicción de forma inequívoca
  String get uniqueKey => '$goalName-$category';

  String get message {
    if (monthsNeeded <= 0) {
      return '¡Ya tienes suficiente para "$goalName" si rediriges ese gasto!';
    }
    return 'Si dejas de gastar ${monthlyExpense.toStringAsFixed(0)} €/mes en $category, alcanzarás "$goalName" en $monthsNeeded meses.';
  }
}

final goalPredictionProvider = Provider<List<GoalPrediction>>((ref) {
  final transactions = ref.watch(transactionListNotifierProvider).value ?? [];
  final goals = ref.watch(goalListNotifierProvider).value ?? [];
  final deletedPredictions = ref.watch(deletedPredictionsProvider);

  if (transactions.isEmpty || goals.isEmpty) return [];

  // OPTIMIZACIÓN: Pre-filtrar transacciones por fecha y tipo UNA sola vez
  final now = DateTime.now();
  final cutoffDate = DateTime(now.year, now.month - 3 + 1, 1);

  final validExpenses = transactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            !t.date.isBefore(
              cutoffDate,
            ), // Evita problemas de exclusión estricta de .isAfter
      )
      .toList();

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
    // Calculamos el promedio usando el set ya pre-filtrado
    final monthlyExpense = _calculateAverageFromFiltered(
      validExpenses,
      category,
      3,
    );
    if (monthlyExpense <= 0) continue;

    for (final goal in goals) {
      final tempPrediction = GoalPrediction(
        goalName: goal.title,
        category: category.name,
        monthlyExpense: monthlyExpense,
        monthsNeeded: 0, // Se recalcula abajo
      );

      // Comprobamos si fue eliminada usando su propiedad única
      if (deletedPredictions.contains(tempPrediction.uniqueKey)) continue;

      final remaining = goal.targetAmount - goal.currentAmount;
      if (remaining <= 0) continue;

      final monthsNeeded = (remaining / monthlyExpense).ceil();

      predictions.add(
        GoalPrediction(
          goalName: goal.title,
          category: category.name,
          monthlyExpense: monthlyExpense,
          monthsNeeded: monthsNeeded,
        ),
      );
    }
  }

  predictions.sort((a, b) => a.monthsNeeded.compareTo(b.monthsNeeded));
  return predictions;
});

// Función auxiliar optimizada
double _calculateAverageFromFiltered(
  List<Transaction> filteredTransactions,
  ExpenseSubCategory sub,
  int months,
) {
  final totalInPeriod = filteredTransactions
      .where((t) => t.subCategory == sub)
      .fold(0.0, (sum, t) => sum + t.amount);

  return totalInPeriod / months;
}

// --- NOTIFIER PARA DESECHADOS ---
final deletedPredictionsProvider =
    NotifierProvider<DeletedPredictionsNotifier, Set<String>>(() {
      return DeletedPredictionsNotifier();
    });

class DeletedPredictionsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void deletePrediction(String key) {
    state = {...state, key};
  }

  void resetDeleted() => state = {};
}
