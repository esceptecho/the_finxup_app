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

// Provider para almacenar la consulta de búsqueda actual
final debtSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});


// 1. Provider para almacenar la moneda seleccionada actualmente
final selectedCurrencyProvider = StateProvider<CurrencyType>((ref) {
  return CurrencyType.usd; // Moneda por defecto inicial
});

// 2. Total Deudas filtrado por moneda
final totalDeudasProvider = Provider<double>((ref) {
  final debts = ref.watch(debtListProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);

  return debts
      .where(
        (d) => d.esDeuda && !d.pagado && d.currencyType == selectedCurrency,
      )
      .fold(0.0, (sum, d) => sum + d.cantidad);
});

// 3. Total Préstamos filtrado por moneda
final totalPrestamosProvider = Provider<double>((ref) {
  final debts = ref.watch(debtListProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);

  return debts
      .where(
        (d) => !d.esDeuda && !d.pagado && d.currencyType == selectedCurrency,
      )
      .fold(0.0, (sum, d) => sum + d.cantidad);
});

// 4. Balance calculado (Préstamos - Deudas) para la moneda seleccionada
final balanceProvider = Provider<double>((ref) {
  final totalPrestamos = ref.watch(totalPrestamosProvider);
  final totalDeudas = ref.watch(totalDeudasProvider);

  // Puedes cambiar el orden de la resta según consideres un balance positivo o negativo
  return totalPrestamos - totalDeudas;
});
