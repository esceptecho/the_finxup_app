// 1. Provider para calcular las finanzas eficientemente (Memoizado)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';

// 1. Provider para calcular las finanzas eficientemente (Memoizado)
final financialSummaryProvider = Provider.autoDispose((ref) {
  final transactionsAsync = ref.watch(transactionListNotifierProvider);

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      final double income = transactions
          .where((tx) => tx.type == TransactionType.income)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final double expense = transactions
          .where((tx) => tx.type == TransactionType.expense)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final double balance = income - expense;

      // Cálculo del porcentaje mejorado
      final double percentage;
      if (income == 0 && expense == 0) {
        percentage = 0.0; // Sin transacciones
      } else if (income == 0) {
        percentage = -100.0; // Solo gastos
      } else if (expense == 0) {
        percentage = 100.0; // Solo ingresos
      } else {
        // Porcentaje del balance respecto al mayor valor
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

    final String sign = amount > 0 ? '+' : '-';
    final String formattedNumber = amount
        .abs()
        .toStringAsFixed(2)
        .replaceAllMapped(_numericRegex, (Match m) => '${m[1]},');

    return '$sign$formattedNumber';
  }

  /// Formatea un balance mostrando el estado financiero
  static String formatBalance(double balance) {
    return formatAmount(balance);
  }
}
