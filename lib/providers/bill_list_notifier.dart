import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/providers/bill_notifiers.dart';

class BillListState {
  final List<Bill> allBills;
  final bool isExpanded;
  final int limit;

  BillListState({
    required this.allBills,
    this.isExpanded = false,
    this.limit = 2,
  });

  BillListState copyWith({List<Bill>? allBills, bool? isExpanded}) {
    return BillListState(
      allBills: allBills ?? this.allBills,
      isExpanded: isExpanded ?? this.isExpanded,
      limit: limit,
    );
  }
}

class BillListNotifier extends Notifier<BillListState> {
  @override
  BillListState build() {
    final asyncBills = ref.watch(billListNotifierProvider);

    final bills = asyncBills.maybeWhen(
      data: (list) => list,
      orElse: () => <Bill>[],
    );

    return BillListState(allBills: bills);
  }

  void toggleExpansion() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }
}

final billListProvider = NotifierProvider<BillListNotifier, BillListState>(
  BillListNotifier.new,
);

final filteredBillsProvider = Provider<List<Bill>>((ref) {
  final uiState = ref.watch(billListProvider);

  // OJO: Si tu modelo Bill usa otro nombre de variable para la fecha (ej. dueDate), cámbialo aquí.
  final sortedList = List<Bill>.from(uiState.allBills)
    ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

  if (uiState.isExpanded) {
    return sortedList;
  } else {
    return sortedList.take(uiState.limit).toList();
  }
});
