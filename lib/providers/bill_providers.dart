import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

// 1. Provider para el Box (asegúrate de abrir 'bills' en tu main)
final billsBoxProvider = Provider<Box<Bill>>((ref) {
  return Hive.box<Bill>('bills');
});

// 2. Provider para el Repositorio
final billRepositoryProvider = Provider<BillRepository>((ref) {
  final box = ref.watch(billsBoxProvider);
  return BillRepository(box);
});

// 3. (OPCIONAL) StreamProvider para que la UI se actualice sola
final billsStreamProvider = StreamProvider<List<Bill>>((ref) {
  final repo = ref.watch(billRepositoryProvider);
  return repo.watchBills();
});
