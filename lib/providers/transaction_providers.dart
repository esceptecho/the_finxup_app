import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import '../models/hive_transaction_model.dart';

/* providers para que cualquier parte de la app pueda usar este repositorio.
Aquí definimos los providers que exponen el Box de Hive y el repositorio a toda la app.
La funcion de estos providers es permitir que cualquier widget o clase pueda acceder a 
los datos de las transacciones sin tener que preocuparse por cómo se almacenan o gestionan,
y para facilitar la integración con Riverpod para la gestión del estado.
Esto es útil para desacoplar la lógica de acceso a datos del resto de la app,
y para facilitar el testing y la escalabilidad.
Los providers también permiten que la UI se actualice automáticamente cuando los datos cambian, 
especialmente si usamos un StreamProvider para escuchar cambios en Hive. */

// 1. Provider para el Box (asumiendo que ya está abierto en el main)
final transactionsBoxProvider = Provider<Box<Transaction>>((ref) {
  return Hive.box<Transaction>('transactions');
});

// 2. Provider para el Repositorio
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final box = ref.watch(transactionsBoxProvider);
  return TransactionRepository(box);
});

// 3. (OPCIONAL) StreamProvider para que la UI se actualice sola
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactions();
});

/* Con estos providers, cualquier widget puede usar 'ref.watch(transactionsStreamProvider)' 
para obtener la lista de transacciones y actualizarse automáticamente cuando cambien,
o usar 'ref.watch(transactionRepositoryProvider)' para acceder a métodos específicos del repositorio 
como 'saveTransaction' o 'deleteTransaction'. */