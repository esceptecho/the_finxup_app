import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/repositories/debt_repository.dart';
import 'package:hive_ce/hive_ce.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final box = Hive.box<Debt>('debts');
  return DebtRepository(box);
});

final debtListProvider = NotifierProvider<DebtListNotifier, List<Debt>>(() {
  return DebtListNotifier();
});

class DebtListNotifier extends Notifier<List<Debt>> {
  late DebtRepository _repository;

  @override
  List<Debt> build() {
    // Usamos watch en lugar de read
    _repository = ref.watch(debtRepositoryProvider);
    return _repository.getAllDebts();
  }

  Future<void> addDebt(Debt debt) async {
    await _repository.addDebt(debt);
    state = _repository.getAllDebts();
  }

  Future<void> togglePagado(int index) async {
    final debt = state[index];
    final updatedDebt = debt.copyWith(pagado: !debt.pagado);
    await _repository.updateDebt(index, updatedDebt);
    state = _repository.getAllDebts();
  }

  Future<void> deleteDebt(int index) async {
    await _repository.deleteDebt(index);
    state = _repository.getAllDebts();
  }
}

// Providers independientes para los totales (Estado derivado)
final totalDeudasProvider = Provider<double>((ref) {
  final debts = ref.watch(debtListProvider);
  return debts
      .where((d) => d.esDeuda && !d.pagado)
      .fold(0, (sum, d) => sum + d.cantidad);
});

final totalPrestamosProvider = Provider<double>((ref) {
  final debts = ref.watch(debtListProvider);
  return debts
      .where((d) => !d.esDeuda && !d.pagado)
      .fold(0, (sum, d) => sum + d.cantidad);
});

// Provider para almacenar la consulta de búsqueda actual
final debtSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});
