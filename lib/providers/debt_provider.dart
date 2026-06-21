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
    _repository = ref.watch(debtRepositoryProvider);
    return _repository.getAllDebts();
  }

  Future<void> addDebt(Debt debt) async {
    await _repository.addDebt(debt);
    state = _repository.getAllDebts();
  }

  // --- ¡NUEVO MÉTODO AGREGADO AQUÍ! ---
  // Este es el método que le hacía falta a tu DebtDetailScreen
  Future<void> updateDebt(Debt updatedDebt) async {
    await _repository.updateDebt(updatedDebt.id, updatedDebt);
    state = _repository
        .getAllDebts(); // Notifica a la app para redibujar los cambios
  }

  // Método actualizado para usar ID en lugar de índice
  Future<void> togglePagado(String id) async {
    final debt = _repository.getDebtById(id);
    if (debt != null) {
      final updatedDebt = debt.copyWith(pagado: !debt.pagado);
      await _repository.updateDebt(id, updatedDebt);
      state = _repository.getAllDebts();
    }
  }

  // Método actualizado para eliminar por ID
  Future<void> deleteDebt(String id) async {
    await _repository.deleteDebt(id);
    state = _repository.getAllDebts();
  }

  // Método auxiliar para obtener deuda por ID
  Debt? getDebtById(String id) {
    return _repository.getDebtById(id);
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

  return totalPrestamos - totalDeudas;
});

