import 'package:hive/hive.dart';
import 'package:the_finxup_app/models/debt_model.dart';

class DebtRepository {
  final Box<Debt> _box = Hive.box<Debt>('debts');

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
