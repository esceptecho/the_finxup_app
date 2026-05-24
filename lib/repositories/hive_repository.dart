import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/utils/transaction_utils.dart';
import 'package:time_machine/time_machine.dart';
import '../models/hive_transaction_model.dart';

/* Este repositorio es una capa de abstracción sobre Hive, 
para que el resto de la app no tenga que lidiar directamente con Hive.
Vamos a expandir la clase para incluir los métodos CRUD básicos: obtener, guardar, eliminar y escuchar cambios.
Usaremos un repositorio genérico o específico para Transaction. */

class TransactionRepository {
  final Box<Transaction> _box;

  TransactionRepository(this._box);

  // Obtener todas las transacciones
  List<Transaction> getAllTransactions() {
    return _box.values.toList();
  }

  // Guardar o actualizar (HiveObject tiene la llave interna)
  // actualizar es lo mismo que guardar, porque Hive usa la misma clave para actualizar
  Future<void> saveTransaction(Transaction transaction) async {
    print(
      '💾 HIVE: Guardando transacción: ${transaction.description} - \$${transaction.amount}',
    );
    await _box.put(transaction.id, transaction);
    print(
      '✅ HIVE: Transacción guardada con éxito. Total en box: ${_box.length}',
    );
  }

  // Eliminar
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  // Escuchar cambios en tiempo real (Súper útil para Riverpod)
  Stream<List<Transaction>> watchTransactions() {
    return _box.watch().map((_) => getAllTransactions());
  }
}

// goal_repository.dart
class GoalRepository {
  final Box<Goal> _box;
  GoalRepository(this._box);

  List<Goal> getAll() => _box.values.toList();
  Future<void> save(Goal goal) async => await _box.put(goal.id, goal);
  Future<void> delete(String id) async => await _box.delete(id);
}

// providers.dart
final goalsBoxProvider = Provider<Box<Goal>>((ref) => Hive.box<Goal>('goals'));

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(ref.watch(goalsBoxProvider));
});

final goalListNotifierProvider =
    AsyncNotifierProvider<GoalListNotifier, List<Goal>>(GoalListNotifier.new);

class GoalListNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    // IMPORTANTE: Usa ref.watch para que si el repo cambia, el notifier también
    final repo = ref.watch(goalRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Goal goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(goalRepositoryProvider);
      await repo.save(goal);
      return repo.getAll(); // Retornamos la lista fresca
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(goalRepositoryProvider);
      await repo.delete(id);
      return repo.getAll();
    });
  }
}

// bill_repository.dart
class BillRepository {
  final Box<Bill> _box;
  BillRepository(this._box);

  List<Bill> getAll() => _box.values.toList();
  Future<void> save(Bill bill) async => await _box.put(bill.id, bill);
  Future<void> delete(String id) async => await _box.delete(id);

  Stream<List<Bill>> watchBills() {
    // Asumiendo que la variable de tu Box se llama 'box' (o '_box')
    // Esto escucha los cambios en Hive y retorna la lista actualizada
    return _box.watch().map((event) {
      return _box.values.toList();
    });
  }
}

// providers.dart
final billsBoxProvider = Provider<Box<Bill>>((ref) => Hive.box<Bill>('bills'));

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(ref.watch(billsBoxProvider));
});

final billListNotifierProvider =
    AsyncNotifierProvider<BillListNotifier, List<Bill>>(BillListNotifier.new);

// ########## Este provider escuchará a ambos y devolverá un objeto que el calendario pueda entender ##########
// Este provider combina ambos AsyncNotifiers
// Va a leer Transactions, Bills (y proyectar sus recurrencias) y Goals.
final calendarEventsProvider =
    Provider<AsyncValue<Map<DateTime, List<dynamic>>>>((ref) {
      final txsAsync = ref.watch(transactionListNotifierProvider);
      final billsAsync = ref.watch(billListNotifierProvider);
      final goalsAsync = ref.watch(goalListNotifierProvider);

      // Combinamos los 3 providers
      if (txsAsync is AsyncData &&
          billsAsync is AsyncData &&
          goalsAsync is AsyncData) {
        final Map<DateTime, List<dynamic>> eventMap = {};

        final transactions = txsAsync.value!;
        final bills = billsAsync.value!;
        final goals = goalsAsync.value!;

        // 2. Añadir Metas (Goals) - Usualmente por su fecha límite
        for (var goal in goals) {
          // Asumiendo que tu modelo Goal tiene un campo targetDate
          final date = DateUtils.dateOnly(goal.targetDate);
          eventMap.putIfAbsent(date, () => []).add(goal);
        }

        // 3. Proyectar Transactions y Bills según su Recurrencia
        for (var transaction in transactions) {
          _projectTransactionOccurrences(transaction, eventMap);
        }

        for (var bill in bills) {
          _projectBillOccurrences(bill, eventMap);
        }

        return AsyncValue.data(eventMap);
      }
      return const AsyncValue.loading();
    });

// Función auxiliar para proyectar fechas futuras
void _projectBillOccurrences(Bill bill, Map<DateTime, List<dynamic>> map) {
  // 1. Convertimos el DateTime nativo a LocalDate de time_machine.
  // Esto elimina automáticamente la hora, los minutos y los segundos,
  // cumpliendo la misma función que hacía DateUtils.dateOnly().
  LocalDate current = LocalDate.dateTime(bill.dueDate);

  // 2. Establecemos el límite proyectando hacia adelante.
  // En lugar de usar DateTime y Duration, usamos LocalDate.today()
  // y sumamos un Periodo de 365 días (1 año).
  LocalDate limit = LocalDate.today().add(Period(days: 366));

  // 3. Caso base: Si es de una sola vez, la agregamos y terminamos.
  if (bill.recurrence == 'Única vez') {
    // toDateTimeUnspecified() convierte el LocalDate de vuelta a un DateTime
    // estándar (a las 00:00:00) para que coincida con la llave de tu Mapa.
    map.putIfAbsent(current.toDateTimeUnspecified(), () => []).add(bill);
    return;
  }

  // 4. Obtenemos el periodo exacto usando nuestra clase de utilidades.
  final period = TransactionUtilsTM.getPeriod(bill.recurrence);

  // Si no se reconoce la recurrencia (period es null), detenemos la ejecución
  // para evitar un bucle infinito.
  if (period == null) return;

  // 5. Bucle de proyección: Mientras la fecha actual no supere el límite.
  // Usar operadores de comparación (<=) con LocalDate es seguro y directo.
  while (current <= limit) {
    // Agregamos el elemento al mapa convirtiendo la fecha a DateTime.
    map.putIfAbsent(current.toDateTimeUnspecified(), () => []).add(bill);

    // 6. Magia de time_machine: Avanzamos a la siguiente fecha sumando el Period.
    // Esto maneja automáticamente los años bisiestos y los meses que tienen
    // 28, 30 o 31 días (ej. sumar 1 mes al 31 de Enero dará 28 de Febrero).
    current = current.add(period);
  }
}

void _projectTransactionOccurrences(
  Transaction transaction,
  Map<DateTime, List<dynamic>> map,
) {
  // 1. Convertimos la fecha de la transacción a LocalDate.
  LocalDate current = LocalDate.dateTime(transaction.date);

  // 2. Establecemos el límite (en tu código original eran 180 días / ~6 meses).
  LocalDate limit = LocalDate.today().add(Period(days: 180));

  // 3. Caso base: Transacción de una única vez.
  if (transaction.recurrence == 'Única vez') {
    map.putIfAbsent(current.toDateTimeUnspecified(), () => []).add(transaction);
    return;
  }

  // 4. Usamos el utility para obtener el periodo basado en el String de recurrencia.
  final period = TransactionUtilsTM.getPeriod(transaction.recurrence);

  // Prevención de errores si el String no coincide con los del switch.
  if (period == null) return;

  // 5. Bucle hasta alcanzar la fecha límite proyectada.
  while (current <= limit) {
    // Insertamos la transacción en el mapa.
    map.putIfAbsent(current.toDateTimeUnspecified(), () => []).add(transaction);

    // 6. Avanzamos en el tiempo usando la lógica exacta y segura de time_machine.
    // Ya no necesitas 'if/else' manuales para saber si sumas días, semanas o meses.
    current = current.add(period);
  }
}

// Función auxiliar antigua para proyectar fechas futuras
// void _projectBillOccurrences(Bill bill, Map<DateTime, List<dynamic>> map) {

//   DateTime current = DateUtils.dateOnly(bill.dueDate);
//   // Proyectamos, por ejemplo, 6 meses hacia adelante
//   DateTime limit = DateTime.now().add(const Duration(days: 365));

//   if (bill.recurrence == 'Única vez') {
//     map.putIfAbsent(current, () => []).add(bill);
//     return;
//   }

//   while (current.isBefore(limit)) {
//     map.putIfAbsent(current, () => []).add(bill);

//     if (bill.recurrence == 'Diario') {
//       current = current.add(const Duration(days: 1));
//     } else if (bill.recurrence == 'Semanal') {
//       current = current.add(const Duration(days: 7));
//     } else if (bill.recurrence == 'Mensual') {
//       current = DateTime(current.year, current.month + 1, current.day);
//     } else {
//       break;
//     }
//   }
// }

// void _projectTransactionOccurrences(
//   Transaction transaction,
//   Map<DateTime, List<dynamic>> map,
// ) {
//   DateTime current = DateUtils.dateOnly(transaction.date);
//   // Proyectamos, por ejemplo, 6 meses hacia adelante
//   DateTime limit = DateTime.now().add(const Duration(days: 180));

//   if (transaction.recurrence == 'Única vez') {
//     map.putIfAbsent(current, () => []).add(transaction);
//     return;
//   }

//   while (current.isBefore(limit)) {
//     map.putIfAbsent(current, () => []).add(transaction);

//     if (transaction.recurrence == 'Diario') {
//       current = current.add(const Duration(days: 1));
//     } else if (transaction.recurrence == 'Semanal') {
//       current = current.add(const Duration(days: 7));
//     } else if (transaction.recurrence == 'Mensual') {
//       current = DateTime(current.year, current.month + 1, current.day);
//     } else {
//       break;
//     }
//   }
// }

class BillListNotifier extends AsyncNotifier<List<Bill>> {
  @override
  Future<List<Bill>> build() async => ref.read(billRepositoryProvider).getAll();

  Future<void> add(Bill bill) async {
    state = const AsyncLoading();
    await ref.read(billRepositoryProvider).save(bill);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(billRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

/* Si quieres un repositorio genérico para cualquier tipo de HiveObject, podrías hacer algo así:

class HiveRepository<T extends HiveObject> {
  final Box<T> _box;
  HiveRepository(this._box);
  List<T> getAll() => _box.values.toList();
  Future<void> save(T item) => _box.put(item.key, item);
  Future<void> delete(dynamic key) => _box.delete(key);
  Stream<List<T>> watch() => _box.watch().map((_) => getAll());
}
*/
