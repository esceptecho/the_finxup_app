// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_providers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/utils/transaction_utils.dart';

final transactionListNotifierProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(() {
      return TransactionListNotifier();
    });

// Provider para calcular el histórico de una transacción específica
// Detalle de una transacción TransactionDetailScreen
// final transaccionHistoricoProvider = Provider.family<double, String>((
//   ref,
//   transactionId,
// ) {
//   final transactionsAsync = ref.watch(transactionListNotifierProvider);

//   return transactionsAsync.when(
//     data: (transactions) {
//       final transaction = transactions.firstWhere(
//         (t) => t.id == transactionId,
//         orElse: () => throw Exception('Transacción no encontrada'),
//       );
//       final notifier = ref.read(transactionListNotifierProvider.notifier);
//       return notifier.calcularTotalHistorico(transaction);
//     },
//     loading: () => 0.0,
//     error: (_, _) => 0.0,
//   );
// });

final transaccionHistoricoProvider = Provider.family<double, String>((
  ref,
  transactionId,
) {
  final transactionsAsync = ref.watch(transactionListNotifierProvider);

  return transactionsAsync.when(
    data: (transactions) {
      // Usamos firstWhereOrNull de 'package:collection/collection.dart'
      // o simplemente manejamos el estado con un bucle/condicional
      final transaction = transactions.cast<Transaction?>().firstWhere(
            (t) => t?.id == transactionId,
            orElse: () => null,
          );

      if (transaction == null) {
        // En lugar de un throw, retornamos un valor seguro provisional
        return 0.0; 
      }

      final notifier = ref.read(transactionListNotifierProvider.notifier);
      return notifier.calcularTotalHistorico(transaction);
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  // Declaramos el repositorio como late ya que se inicializará en build()
  late final TransactionRepository _repository;

  // Declaramos el StreamSubscription para poder cancelarlo cuando el notifier se destruya
  // Esto es CRUCIAL para evitar memory leaks
  StreamSubscription? _subscription;

  @override
  Future<List<Transaction>> build() async {
    // Obtenemos el repositorio usando ref.watch() para mantener la reactividad
    _repository = ref.watch(transactionRepositoryProvider);

    // INICIO DE LA MAGIA DEL STREAM EN TIEMPO REAL
    // Cada vez que Hive detecta un cambio (add, update, delete), este stream emite un even
    _subscription = _repository.watchTransactions().listen(
      (transactions) {
        // Cuando el stream emite nuevos datos, actualizamos el estado del AsyncNotifier
        // Usamos AsyncData() para indicar que los datos están disponibles y son válidos
        // Esto actualiza AUTOMÁTICAMENTE todos los widgets que estén escuchando este provider
        print(
          '🔄 STREAM: Cambio detectado en Hive. Actualizando UI con ${transactions.length} transacciones',
        );
        state = AsyncData(transactions);
      },
      onError: (error) {
        // Manejamos errores del stream (ej: problemas de conexión con la base de datos)
        // Este valor se usará para el estado inicial mientras el stream no emita nada
        print('❌ STREAM: Error en la escucha de cambios: $error');
        state = AsyncError(error, StackTrace.current);
      },
    );

    // CORRECCIÓN DEL ERROR AQUÍ:
    // ==========================
    // En AsyncNotifier, registramos la limpieza directamente en el build
    // usando ref.onDispose() en lugar de sobrescribir un método externo.
    ref.onDispose(() {
      print(
        '🧹 NOTIFIER: Limpiando recursos y cancelando suscripción al stream',
      );
      _subscription?.cancel();
    });

    // Retornamos los datos iniciales cargados de Hive
    print('📦 NOTIFIER: Cargando datos iniciales desde Hive');
    return _repository.getAllTransactions();
  }

  // VENTAJAS DE ESTE ENFOQUE CON STREAM:
  // ===================================
  // 1. REACTIVIDAD EN TIEMPO REAL: Cualquier cambio en Hive (desde cualquier parte de la app)
  //    actualiza automáticamente la UI sin necesidad de llamar manualmente a métodos
  //
  // 2. DESACOPLAMIENTO: Los métodos addTransaction, deleteTransaction, etc. ahora son más simples
  //    porque NO necesitan recargar manualmente la lista. Solo modifican Hive y el stream
  //    se encarga de notificar el cambio
  //
  // 3. CONSISTENCIA: Todos los widgets que usen este provider siempre mostrarán los mismos datos
  //    porque todos escuchan el mismo stream de cambios
  //
  // 4. MENOS CÓDIGO: Eliminamos todas las llamadas a _repository.getAllTransactions() en los métodos
  //    porque el stream ya se encarga de refrescar la lista automáticamente
  //
  // 5. MEJOR RENDIMIENTO: Solo se actualiza la UI cuando realmente hay cambios en la base de datos
  //    evitando recargas innecesarias

  // MÉTODO REESCRITO: addTransaction AHORA ES MUCHO MÁS SIMPLE
  // =========================================================
  // Ya no necesitamos recargar la lista manualmente. Solo guardamos y el stream hace el resto

  // MÉTODO REESCRITO: addTransaction AHORA ES MUCHO MÁS SIMPLE
  Future<void> addTransaction(Transaction transaction) async {
    print(
      '🔔 NOTIFIER: Iniciando addTransaction para ${transaction.description}',
    );

    state = await AsyncValue.guard(() async {
      // Primero obtenemos la transacción para eliminar sus archivos adjuntos
      await _repository.saveTransaction(transaction);
      print(
        '✅ NOTIFIER: Transacción guardada. El stream actualizará la UI automáticamente',
      );
      return _repository.getAllTransactions();
    });
  }

  // MÉTODO REESCRITO: deleteTransaction TAMBIÉN MÁS SIMPLE
  Future<void> deleteTransaction(String id) async {
    print('🔔 NOTIFIER: Iniciando deleteTransaction para ID: $id');

    state = await AsyncValue.guard(() async {
      final transactions = _repository.getAllTransactions();
      final transactionToDelete = transactions.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('Transacción no encontrada: $id'),
      );

      // Eliminamos archivos físicos del disco
      for (String path in transactionToDelete.attachmentPaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          print('🗑️ Archivo eliminado del disco: $path');
        }
      }

      // Eliminamos la transacción de Hive
      await _repository.deleteTransaction(id);
      print(
        '✅ NOTIFIER: Transacción eliminada. El stream actualizará la UI automáticamente',
      );

      // Retornamos la lista actualizada (aunque el stream hará lo mismo después)
      return _repository.getAllTransactions();
    });
  }

  // MÉTODO REESCRITO: addAttachmentToTransaction
  Future<void> addAttachmentToTransaction(Transaction transaction) async {
    print('📎 NOTIFIER: Iniciando selección de adjunto para ${transaction.id}');

    state = await AsyncValue.guard(() async {
      // Seleccionamos archivo del dispositivo
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        final directory = await getApplicationDocumentsDirectory();

        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
        final String savedPath = '${directory.path}/$fileName';

        // Copiamos el archivo al directorio de la app
        await file.copy(savedPath);

        final List<String> updatedPaths = List<String>.from(
          transaction.attachmentPaths,
        );
        updatedPaths.add(savedPath);

        final updatedTransaction = transaction.copyWith(
          attachmentPaths: updatedPaths,
        );

        // Guardamos la transacción actualizada en Hive
        await _repository.saveTransaction(updatedTransaction);
        print('✅ NOTIFIER: Archivo guardado en $savedPath');
      } else {
        print('ℹ️ NOTIFIER: No se seleccionó ningún archivo');
      }

      // Retornamos la lista actualizada (el stream también la actualizará)
      return _repository.getAllTransactions();
    });
  }

  // MÉTODO REESCRITO: calcularTotalHistorico
  // ======================================================
  // Este método es puramente computacional y no afecta al estado del notifier
  double calcularTotalHistorico(Transaction transaction) {
    // Delegamos la lógica matemática compleja a la clase especializada de aritmética de tiempo
    return TransactionUtilsTM.calculateAccumulatedToNowTM(
      amount: transaction.amount,
      startDate: transaction.date,
      recurrence: transaction.recurrence,
    );
  }

  // MÉTODO REESCRITO: calcularSaldoTotalHastaHoy
  double calcularSaldoTotalHastaHoy(List<Transaction> todasLasTransacciones) {
    double granTotal = 0.0;

    for (var transaccion in todasLasTransacciones) {
      granTotal += calcularTotalHistorico(transaccion);
    }

    return granTotal;
  }

  // MÉTODO NUEVO: getCurrentTransactions - UTILIDAD
  // ==============================================
  // Como ahora tenemos el estado en tiempo real, podemos ofrecer un método
  // para obtener las transacciones actuales desde el estado
  List<Transaction> getCurrentTransactions() {
    return state.maybeWhen(
      data: (transactions) => transactions,
      orElse: () => [],
    );
  }
}











































/* Para manejar el estado de la lista de transacciones en NewHomeScreen,  
usaremos un AsyncNotifier. El TransactionListNotifier se encargará de cargar la lista. */

// final transactionListNotifierProvider =
//     AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(() {
//       return TransactionListNotifier();
//     });


// // Provider para calcular el histórico de una transacción específica
// // Detalle de una transacción	TransactionDetailScreen
// final transaccionHistoricoProvider = Provider.family<double, String>((
//   ref,
//   transactionId,
// ) {
//   final transactionsAsync = ref.watch(transactionListNotifierProvider);

//   return transactionsAsync.when(
//     data: (transactions) {
//       final transaction = transactions.firstWhere(
//         (t) => t.id == transactionId,
//         orElse: () => throw Exception('Transacción no encontrada'),
//       );
//       final notifier = ref.read(transactionListNotifierProvider.notifier);
//       return notifier.calcularTotalHistorico(transaction);
//     },
//     loading: () => 0.0,
//     error: (_, _) => 0.0,
//   );
// });



// Este AsyncNotifier se encargará de cargar la lista de transacciones y manejar las operaciones CRUD.
// class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
//   late final TransactionRepository _repository;

//   @override
//   Future<List<Transaction>> build() async {
//     _repository = ref.watch(transactionRepositoryProvider);
//     return _repository.getAllTransactions();
//   }

//   Future<void> addTransaction(Transaction transaction) async {
//     print(
//       '🔔 NOTIFIER: Iniciando addTransaction para ${transaction.description}',
//     );
//     state = const AsyncValue.loading();

//     state = await AsyncValue.guard(() async {
//       await _repository.saveTransaction(transaction);
//       final newList = _repository.getAllTransactions();
//       print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');
//       return newList;
//     });
//   }

//   Future<void> deleteTransaction(String id) async {
//     print('🔔 NOTIFIER: Iniciando deleteTransaction para ID: $id');
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final transactions = _repository.getAllTransactions();
//       final transactionToDelete = transactions.firstWhere(
//         (t) => t.id == id,
//         orElse: () => throw Exception('Transacción no encontrada: $id'),
//       );

//       for (String path in transactionToDelete.attachmentPaths) {
//         final file = File(path);
//         if (await file.exists()) {
//           await file.delete();
//           print('🗑️ Archivo eliminado del disco: $path');
//         }
//       }

//       await _repository.deleteTransaction(id);
//       final newList = _repository.getAllTransactions();
//       print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');

//       return newList;
//     });
//   }

//   Future<void> addAttachmentToTransaction(Transaction transaction) async {
//     print('📎 NOTIFIER: Iniciando selección de adjunto para ${transaction.id}');
//     state = const AsyncValue.loading();

//     state = await AsyncValue.guard(() async {
//       FilePickerResult? result = await FilePicker.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
//       );

//       if (result != null && result.files.single.path != null) {
//         final File file = File(result.files.single.path!);
//         final directory = await getApplicationDocumentsDirectory();

//         final String fileName =
//             '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
//         final String savedPath = '${directory.path}/$fileName';

//         await file.copy(savedPath);
//         transaction.attachmentPaths.add(savedPath);
//         await _repository.saveTransaction(transaction);

//         final List<String> updatedPaths = List<String>.from(
//           transaction.attachmentPaths,
//         );
//         updatedPaths.add(savedPath);

//         final updatedTransaction = transaction.copyWith(
//           attachmentPaths: updatedPaths,
//         );

//         await _repository.saveTransaction(updatedTransaction);
//         print('✅ NOTIFIER: Archivo guardado en $savedPath');
//       }

//       return _repository.getAllTransactions();
//     });
//   }

//   // 1. El método REESCRITO para calcular dinámicamente usando la utilidad precisa
//   double calcularTotalHistorico(Transaction transaction) {
//     // Delegamos la lógica matemática compleja a la clase especializada de aritmética de tiempo
//     return TransactionUtilsTM.calculateAccumulatedToNowTM(
//       amount: transaction.amount,
//       startDate: transaction.date,
//       recurrence: transaction.recurrence,
//     );
//   }

//   // 2. Obtener la suma total de todo el historial reactivo de forma dinámica
//   double calcularSaldoTotalHastaHoy(List<Transaction> todasLasTransacciones) {
//     double granTotal = 0.0;

//     for (var transaccion in todasLasTransacciones) {
//       granTotal += calcularTotalHistorico(transaccion);
//     }

//     return granTotal;
//   }
// }











// Provider derivado para el saldo total histórico
// final saldoTotalHistoricoProvider = Provider<double>((ref) {
//   final transactionsAsync = ref.watch(transactionListNotifierProvider);

//   return transactionsAsync.when(
//     data: (transactions) {
//       final notifier = ref.read(transactionListNotifierProvider.notifier);
//       return notifier.calcularSaldoTotalHastaHoy(transactions);
//     },
//     loading: () => 0.0,
//     error: (_, _) => 0.0,
//   );
// });


// // ignore_for_file: avoid_print

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:file_picker/file_picker.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:the_finxup_app/models/hive_transaction_model.dart';
// import 'package:the_finxup_app/providers/transaction_providers.dart';
// import 'package:the_finxup_app/repositories/hive_repository.dart';

// /* Para manejar el estado de la lista de transacciones en NewHomeScreen,  
// usaremos un AsyncNotifier (o Notifier si se prefiere algo síncrono).
// Los AsyncNotifiers son útiles para manejar estados que dependen de operaciones asíncronas,
// como cargar datos desde Hive o realizar operaciones CRUD.
// Este TransactionListNotifier se encargará de cargar la lista de transacciones. */

// final transactionListNotifierProvider =
//     AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(() {
//       return TransactionListNotifier();
//     });

// // Provider derivado para el saldo total histórico
// final saldoTotalHistoricoProvider = Provider<double>((ref) {
//   final transactionsAsync = ref.watch(transactionListNotifierProvider);
  
//   return transactionsAsync.when(
//     data: (transactions) {
//       final notifier = ref.read(transactionListNotifierProvider.notifier);
//       return notifier.calcularSaldoTotalHastaHoy(transactions);
//     },
//     loading: () => 0.0,
//     error: (_, _) => 0.0,
//   );
// });

// // Provider para calcular el histórico de una transacción específica
// final transaccionHistoricoProvider = Provider.family<double, String>((ref, transactionId) {
//   final transactionsAsync = ref.watch(transactionListNotifierProvider);
  
//   return transactionsAsync.when(
//     data: (transactions) {
//       final transaction = transactions.firstWhere(
//         (t) => t.id == transactionId,
//         orElse: () => throw Exception('Transacción no encontrada'),
//       );
//       final notifier = ref.read(transactionListNotifierProvider.notifier);
//       return notifier.calcularTotalHistorico(transaction);
//     },
//     loading: () => 0.0,
//     error: (_, _) => 0.0,
//   );
// });    

// // Este AsyncNotifier se encargará de cargar la lista de transacciones y manejar las operaciones CRUD.
// class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
//   late final TransactionRepository _repository;

//   @override
//   Future<List<Transaction>> build() async {
//     // Inicializamos el repositorio leyendo su provider
//     _repository = ref.watch(transactionRepositoryProvider);
//     // Retornamos la data inicial
//     return _repository.getAllTransactions();
//   }

//   Future<void> addTransaction(Transaction transaction) async {
//     print(
//       '🔔 NOTIFIER: Iniciando addTransaction para ${transaction.description}',
//     );
//     // 1. Entramos en estado de carga (opcional, pero recomendado para UX)
//     state = const AsyncValue.loading();

//     // 2. Usamos guard para ejecutar la operación de forma segura
//     state = await AsyncValue.guard(() async {
//       // Guardamos en el disco (Hive)
//       await _repository.saveTransaction(transaction);
//       // Retornamos la lista actualizada para que se convierta en el nuevo estado
//       // return _repository.getAllTransactions();
//       final newList = _repository.getAllTransactions();
//       print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');
//       return newList;
//     });
//   }

//   Future<void> deleteTransaction(String id) async {
//     print('🔔 NOTIFIER: Iniciando deleteTransaction para ID: $id');
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       // 1. PRIMERO obtener la transacción antes de borrarla
//       final transactions = _repository.getAllTransactions();
//       final transactionToDelete = transactions.firstWhere(
//         (t) => t.id == id,
//         orElse: () => throw Exception('Transacción no encontrada: $id'),
//       );

//       // 2. Borrar archivos físicos del disco
//       for (String path in transactionToDelete.attachmentPaths) {
//         final file = File(path);
//         if (await file.exists()) {
//           await file.delete();
//           print('🗑️ Archivo eliminado del disco: $path');
//         }
//       }

//       // 3. LUEGO borrar de la base de datos
//       await _repository.deleteTransaction(id);

//       // 4. Obtener la lista actualizada
//       final newList = _repository.getAllTransactions();
//       print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');

//       return newList;
//     });
//   }

//   Future<void> addAttachmentToTransaction(Transaction transaction) async {
//     print('📎 NOTIFIER: Iniciando selección de adjunto para ${transaction.id}');

//     // 1. Ponemos el estado en carga para que la UI reaccione (opcional)
//     state = const AsyncValue.loading();

//     state = await AsyncValue.guard(() async {
//       // 2. Abrir el selector de archivos
//       FilePickerResult? result = await FilePicker.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
//       );

//       if (result != null && result.files.single.path != null) {
//         final File file = File(result.files.single.path!);

//         // 3. Preparar la ruta permanente en el dispositivo
//         // Obtenemos el directorio "Documents" de la app
//         final directory = await getApplicationDocumentsDirectory();

//         // Creamos un nombre único para evitar sobrescribir archivos con el mismo nombre
//         final String fileName =
//             '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
//         final String savedPath = '${directory.path}/$fileName';

//         // 4. Copiar el archivo desde la carpeta temporal a la permanente
//         await file.copy(savedPath);

//         // 5. Actualizar el modelo de Hive
//         // Importante: attachmentPaths debe ser mutable (List<String>)
//         transaction.attachmentPaths.add(savedPath);

//         // 6. Persistir en Hive a través del repositorio
//         // El repositorio debería manejar la lógica de 'box.put(transaction.id, transaction)'
//         await _repository.saveTransaction(transaction);

//         // ⚡ IMPORTANTE: Crear una copia de la lista de paths
//         final List<String> updatedPaths = List<String>.from(
//           transaction.attachmentPaths,
//         );
//         updatedPaths.add(savedPath);

//         // ⚡ IMPORTANTE: Crear una copia modificada de la transacción
//         final updatedTransaction = transaction.copyWith(
//           attachmentPaths: updatedPaths,
//         );

//         // Guardar la transacción actualizada
//         await _repository.saveTransaction(updatedTransaction);

//         print('✅ NOTIFIER: Archivo guardado en $savedPath');
//       }

//       // 7. Retornamos la lista actualizada
//       return _repository.getAllTransactions();
//     });
//   }

//   // 1. El método para calcular el total de una sola transacción hasta hoy
//   double calcularTotalHistorico(Transaction transaction) {
    
//     // Asumo que tu modelo tiene una propiedad como 'amount' o 'value'
//     double valorDeTransaccion = transaction.amount;

//     if (transaction.recurrence == 'Única vez') {
//       return valorDeTransaccion;
//     }

//     DateTime current = DateUtils.dateOnly(transaction.date);
//     DateTime hoy = DateUtils.dateOnly(DateTime.now());

//     // Si la transacción inicia en el futuro, no ha generado valor histórico aún.
//     if (current.isAfter(hoy)) return 0.0;

//     int contadorOcurrencias = 0;

//     // Contamos cuántas veces ocurre desde el inicio hasta hoy (inclusive)
//     while (current.isBefore(hoy) || current.isAtSameMomentAs(hoy)) {
//       contadorOcurrencias++;

//       if (transaction.recurrence == 'Diario') {
//         current = current.add(const Duration(days: 1));
//       } else if (transaction.recurrence == 'Semanal') {
//         current = current.add(const Duration(days: 7));
//       } else if (transaction.recurrence == 'Mensual') {
//         current = DateTime(current.year, current.month + 1, current.day);
//       } else {
//         break;
//       }
//     }

//     return contadorOcurrencias * valorDeTransaccion;
//   }

//   // 2. Obtener la suma total de todo el historial
//   double calcularSaldoTotalHastaHoy(List<Transaction> todasLasTransacciones) {
//     double granTotal = 0.0;

//     for (var transaccion in todasLasTransacciones) {
//       granTotal += calcularTotalHistorico(transaccion);
//     }

//     return granTotal;
//   }
// }
