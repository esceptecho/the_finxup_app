import 'package:hive_ce/hive_ce.dart';
import 'package:the_finxup_app/models/debt_model.dart';

// class DebtRepository {
//   // Pasamos la Box como una dependencia requerida
//   final Box<Debt> _box;

//   DebtRepository(this._box);

//   List<Debt> getAllDebts() {
//     return _box.values.toList();
//   }

//   Future<void> addDebt(Debt debt) async {
//     await _box.add(debt);
//   }

//   Future<void> updateDebt(int index, Debt debt) async {
//     await _box.putAt(index, debt);
//   }

//   Future<void> deleteDebt(int index) async {
//     await _box.deleteAt(index);
//   }
// }

class DebtRepository {
  final Box<Debt> _box;

  DebtRepository(this._box);

  // Obtener todas las deudas
  List<Debt> getAllDebts() {
    return _box.values.toList();
  }

  // Obtener deuda por ID
  Debt? getDebtById(String id) {
    try {
      final key = _box.keys.firstWhere(
        (key) => _box.get(key)?.id == id,
        orElse: () => null,
      );
      return key != null ? _box.get(key) : null;
    } catch (e) {
      return null;
    }
  }

  // Agregar nueva deuda
  Future<void> addDebt(Debt debt) async {
    await _box.add(debt);
  }

  // Actualizar deuda por ID
  Future<void> updateDebt(String id, Debt updatedDebt) async {
    final key = _getKeyById(id);
    if (key != null) {
      await _box.put(key, updatedDebt);
    }
  }

  // Eliminar deuda por ID
  Future<void> deleteDebt(String id) async {
    final key = _getKeyById(id);
    if (key != null) {
      await _box.delete(key);
    }
  }

  // Método auxiliar para obtener la clave Hive por ID
  int? _getKeyById(String id) {
    try {
      return _box.keys.firstWhere((key) => _box.get(key)?.id == id);
    } catch (e) {
      return null;
    }
  }
}
