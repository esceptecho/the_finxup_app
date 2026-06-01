import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/repositories/debt_repository.dart';

// Provider del Repositorio
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository();
});

// Provider del Notifier que maneja la lista de deudas
final debtListProvider = NotifierProvider<DebtListNotifier, List<Debt>>(() {
  return DebtListNotifier();
});

class DebtListNotifier extends Notifier<List<Debt>> {
  late DebtRepository _repository;

  @override
  List<Debt> build() {
    _repository = ref.read(debtRepositoryProvider);
    return _repository.getAllDebts();
  }

  Future<void> addDebt(Debt debt) async {
    await _repository.addDebt(debt);
    state = _repository.getAllDebts(); // Actualiza el estado reactivo
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

  // Métodos de cálculo computados
  double get totalDeudas => state
      .where((d) => d.esDeuda && !d.pagado)
      .fold(0, (sum, d) => sum + d.cantidad);

  double get totalPrestamos => state
      .where((d) => !d.esDeuda && !d.pagado)
      .fold(0, (sum, d) => sum + d.cantidad);
}
