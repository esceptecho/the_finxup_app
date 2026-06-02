import 'package:hive_ce/hive_ce.dart';
import 'package:the_finxup_app/models/debt_model.dart';

class DebtRepository {
  // Pasamos la Box como una dependencia requerida
  final Box<Debt> _box;

  DebtRepository(this._box);

  List<Debt> getAllDebts() {
    return _box.values.toList();
  }

  Future<void> addDebt(Debt debt) async {
    await _box.add(debt);
  }

  Future<void> updateDebt(int index, Debt debt) async {
    await _box.putAt(index, debt);
  }

  Future<void> deleteDebt(int index) async {
    await _box.deleteAt(index);
  }
}
