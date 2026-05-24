import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';

class ListState {
  final List<Transaction> allTransactions;
  final bool isExpanded;
  final int limit;

  ListState({
    required this.allTransactions,
    this.isExpanded = false,
    this.limit = 2,
  });

  ListState copyWith({List<Transaction>? allTransactions, bool? isExpanded}) {
    return ListState(
      allTransactions: allTransactions ?? this.allTransactions,
      isExpanded: isExpanded ?? this.isExpanded,
      limit: limit,
    );
  }
}

class ListNotifier extends Notifier<ListState> {
  @override
  ListState build() {
    // 1. Escuchamos el provider que trae las transacciones de la DB
    final asyncTransactions = ref.watch(transactionListNotifierProvider);

    // 2. Extraemos la lista si ya está cargada (data), de lo contrario lista vacía
    final transactions = asyncTransactions.maybeWhen(
      data: (list) => list,
      orElse: () => <Transaction>[],
    );

    return ListState(allTransactions: transactions);
  }

  void toggleExpansion() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }
}

// El Provider de la lógica de UI
final listProvider = NotifierProvider<ListNotifier, ListState>(ListNotifier.new);

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) { 
  final uiState = ref.watch(listProvider);
  
  // Clonamos y ordenamos por fecha (Más recientes primero)
  final sortedList = List<Transaction>.from(uiState.allTransactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  // Aplicamos el límite si no está expandido
  if (uiState.isExpanded) {
    return sortedList;
  } else {
    return sortedList.take(uiState.limit).toList();
  }
});