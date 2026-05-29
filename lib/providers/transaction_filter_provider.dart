// Enum para los tipos de filtro
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';

enum TransactionFilter { all, income, expense }

// Provider para el filtro seleccionado (reactivo)
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

// Provider para la lista filtrada de transacciones
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactionsAsync = ref.watch(transactionListNotifierProvider);
  final filter = ref.watch(transactionFilterProvider);

  return transactionsAsync.when(
    data: (transactions) {
      switch (filter) {
        case TransactionFilter.all:
          return transactions;
        case TransactionFilter.income:
          return transactions
              .where((t) => t.type == TransactionType.income)
              .toList();
        case TransactionFilter.expense:
          return transactions
              .where((t) => t.type == TransactionType.expense)
              .toList();
      }
    },
    loading: () => [],
    error: (_, _) => [],
  );
});

// Provider para el total de ingresos históricos
final totalIngresosHistoricosProvider = Provider<double>((ref) {
  final transactionsAsync = ref.watch(transactionListNotifierProvider);

  return transactionsAsync.when(
    data: (transactions) {
      return transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.totalAccumulatedValue);
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

// Provider para el total de gastos históricos
final totalGastosHistoricosProvider = Provider<double>((ref) {
  final transactionsAsync = ref.watch(transactionListNotifierProvider);

  return transactionsAsync.when(
    data: (transactions) {
      return transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.totalAccumulatedValue);
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

// Provider para el balance histórico (ingresos - gastos)
final balanceHistoricoProvider = Provider<double>((ref) {
  final ingresos = ref.watch(totalIngresosHistoricosProvider);
  final gastos = ref.watch(totalGastosHistoricosProvider);
  return ingresos - gastos;
});
