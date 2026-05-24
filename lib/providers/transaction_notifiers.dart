// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_providers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

/* Para manejar el estado de la lista de transacciones en NewHomeScreen,  
usaremos un AsyncNotifier (o Notifier si se prefiere algo síncrono).
Los AsyncNotifiers son útiles para manejar estados que dependen de operaciones asíncronas,
como cargar datos desde Hive o realizar operaciones CRUD.
Este TransactionListNotifier se encargará de cargar la lista de transacciones. */

final transactionListNotifierProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(() { 
      return TransactionListNotifier();
    });

// Este AsyncNotifier se encargará de cargar la lista de transacciones y manejar las operaciones CRUD.
class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  late final TransactionRepository _repository;

  @override
  Future<List<Transaction>> build() async {
    // Inicializamos el repositorio leyendo su provider
    _repository = ref.watch(transactionRepositoryProvider);
    // Retornamos la data inicial
    return _repository.getAllTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    print(
      '🔔 NOTIFIER: Iniciando addTransaction para ${transaction.description}',
    );
    // 1. Entramos en estado de carga (opcional, pero recomendado para UX)
    state = const AsyncValue.loading();

    // 2. Usamos guard para ejecutar la operación de forma segura
    state = await AsyncValue.guard(() async {
      // Guardamos en el disco (Hive)
      await _repository.saveTransaction(transaction);
      // Retornamos la lista actualizada para que se convierta en el nuevo estado
      // return _repository.getAllTransactions();
      final newList = _repository.getAllTransactions();
      print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');
      return newList;
    });
  }

  Future<void> deleteTransaction(String id) async {
    print('🔔 NOTIFIER: Iniciando deleteTransaction para ID: $id');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. PRIMERO obtener la transacción antes de borrarla
      final transactions = _repository.getAllTransactions();
      final transactionToDelete = transactions.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('Transacción no encontrada: $id'),
      );

      // 2. Borrar archivos físicos del disco
      for (String path in transactionToDelete.attachmentPaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          print('🗑️ Archivo eliminado del disco: $path');
        }
      }

      // 3. LUEGO borrar de la base de datos
      await _repository.deleteTransaction(id);

      // 4. Obtener la lista actualizada
      final newList = _repository.getAllTransactions();
      print('📈 NOTIFIER: Estado actualizado. Nuevos items: ${newList.length}');

      return newList;
    });
  }

  Future<void> addAttachmentToTransaction(Transaction transaction) async {
    print('📎 NOTIFIER: Iniciando selección de adjunto para ${transaction.id}');

    // 1. Ponemos el estado en carga para que la UI reaccione (opcional)
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // 2. Abrir el selector de archivos
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);

        // 3. Preparar la ruta permanente en el dispositivo
        // Obtenemos el directorio "Documents" de la app
        final directory = await getApplicationDocumentsDirectory();

        // Creamos un nombre único para evitar sobrescribir archivos con el mismo nombre
        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
        final String savedPath = '${directory.path}/$fileName';

        // 4. Copiar el archivo desde la carpeta temporal a la permanente
        await file.copy(savedPath);

        // 5. Actualizar el modelo de Hive
        // Importante: attachmentPaths debe ser mutable (List<String>)
        transaction.attachmentPaths.add(savedPath);

        // 6. Persistir en Hive a través del repositorio
        // El repositorio debería manejar la lógica de 'box.put(transaction.id, transaction)'
        await _repository.saveTransaction(transaction);

        print('✅ NOTIFIER: Archivo guardado en $savedPath');
      }

      // 7. Retornamos la lista actualizada
      return _repository.getAllTransactions();
    });
  }

  // 1. El método para calcular el total de una sola transacción hasta hoy
  double calcularTotalHistorico(Transaction transaction) {
    // Asumo que tu modelo tiene una propiedad como 'amount' o 'value'
    double valorDeTransaccion = transaction.amount;

    if (transaction.recurrence == 'Única vez') {
      return valorDeTransaccion;
    }

    DateTime current = DateUtils.dateOnly(transaction.date);
    DateTime hoy = DateUtils.dateOnly(DateTime.now());

    // Si la transacción inicia en el futuro, no ha generado valor histórico aún.
    if (current.isAfter(hoy)) return 0.0;

    int contadorOcurrencias = 0;

    // Contamos cuántas veces ocurre desde el inicio hasta hoy (inclusive)
    while (current.isBefore(hoy) || current.isAtSameMomentAs(hoy)) {
      contadorOcurrencias++;

      if (transaction.recurrence == 'Diario') {
        current = current.add(const Duration(days: 1));
      } else if (transaction.recurrence == 'Semanal') {
        current = current.add(const Duration(days: 7));
      } else if (transaction.recurrence == 'Mensual') {
        current = DateTime(current.year, current.month + 1, current.day);
      } else {
        break;
      }
    }

    return contadorOcurrencias * valorDeTransaccion;
  }

  // 2. Obtener la suma total de todo el historial
  double calcularSaldoTotalHastaHoy(List<Transaction> todasLasTransacciones) {
    double granTotal = 0.0;

    for (var transaccion in todasLasTransacciones) {
      granTotal += calcularTotalHistorico(transaccion);
    }

    return granTotal;
  }
}
