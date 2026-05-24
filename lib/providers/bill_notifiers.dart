import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

final billListNotifierProvider =
    AsyncNotifierProvider<BillListNotifier, List<Bill>>(() {
      return BillListNotifier();
    });

class BillListNotifier extends AsyncNotifier<List<Bill>> {
  late final BillRepository _repository;

  @override
  Future<List<Bill>> build() async {
    _repository = ref.watch(billRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> addBill(Bill bill) async {
    // Si tu modelo no tiene "description", cambia esto por el campo de texto (ej. title, name)
    print('🔔 NOTIFIER: Iniciando addBill para ${bill.title}');
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository.save(bill);
      final newList = _repository.getAll();
      print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');
      return newList;
    });
  }

  Future<void> deleteBill(String id) async {
    print('🔔 NOTIFIER: Iniciando deleteBill para ID: $id');
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      final newList = _repository.getAll();
      print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');
      return newList;
    });
  }
}
