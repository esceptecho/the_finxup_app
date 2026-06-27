import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/utils/transaction_utils.dart'; // <-- nuevo

final financialSummaryProvider = Provider.autoDispose((ref) {
  final transactionsAsync = ref.watch(transactionListNotifierProvider);

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      double income = 0.0;
      double expense = 0.0;

      for (final tx in transactions) {
        // Calcula el monto acumulado hasta hoy según la recurrencia
        final accumulated = TransactionUtilsTM.calculateAccumulatedToNowTM(
          amount: tx.amount,
          startDate: tx.date,
          recurrence: tx.recurrence,
        );

        // Suma al total correspondiente según el tipo
        if (tx.type == TransactionType.income) {
          income += accumulated;
        } else if (tx.type == TransactionType.expense) {
          expense += accumulated;
        }
      }

      final double balance = income - expense;

      // Cálculo del porcentaje (mantiene tu lógica actual)
      final double percentage;
      if (income == 0 && expense == 0) {
        percentage = 0.0;
      } else if (income == 0) {
        percentage = -100.0;
      } else if (expense == 0) {
        percentage = 100.0;
      } else {
        final double maxValue = income > expense ? income : expense;
        percentage = (balance / maxValue) * 100;
      }

      return (
        balance: balance,
        income: income,
        expense: expense,
        percentage: percentage,
      );
    },
    orElse: () => (balance: 0.0, income: 0.0, expense: 0.0, percentage: 0.0),
  );
});

// Providers derivados (opcionales, para acceso rápido a partes específicas)
// Solo el número de balance	BalanceCard
final saldoTotalHistoricoProvider = Provider<double>((ref) {
  return ref.watch(financialSummaryProvider).balance;
});

// Solo ingresos totales	IncomeWidget
final totalIncomeProvider = Provider<double>((ref) {
  return ref.watch(financialSummaryProvider).income;
});

// Solo gastos totales	ExpenseWidget
final totalExpenseProvider = Provider<double>((ref) {
  return ref.watch(financialSummaryProvider).expense;
});

// 2. Helper de formateo mejorado
class CurrencyFormatter {
  static final RegExp _numericRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  /// Formatea un porcentaje mostrando el signo correspondiente
  /// Ejemplos: 70.5 -> "+70.50%", -30.0 -> "-30.00%"
  static String formatPercentage(double percentage) {
    if (percentage == 0) return '0.0%';

    final String sign = percentage > 0 ? '+' : '-';
    final String formattedNumber = percentage
        .abs()
        .toStringAsFixed(1)
        .replaceAllMapped(_numericRegex, (Match m) => '${m[1]},');

    return '$sign$formattedNumber%';
  }

  /// Formatea un monto monetario mostrando el signo para valores positivos
  /// Ejemplos: 1000.5 -> "+1,000.50", -500.75 -> "-500.75"
  static String formatAmount(double amount) {
    if (amount == 0) return '0.00';

    final String sign = '\$';
    final String formattedNumber = amount
        .abs()
        .toStringAsFixed(2)
        .replaceAllMapped(_numericRegex, (Match m) => '${m[1]},');

    return '$sign$formattedNumber';
  }

  static String formatDebt(double amount) {
    if (amount == 0) return '0.00';

    final String formattedNumber = amount
        .abs()
        .toStringAsFixed(2)
        .replaceAllMapped(_numericRegex, (Match m) => '${m[1]},');

    return formattedNumber;
  }

  /// Formatea un balance mostrando el estado financiero
  static String formatBalance(double balance) {
    return formatAmount(balance);
  }
}
