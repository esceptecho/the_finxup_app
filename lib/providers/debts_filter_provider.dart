import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';

enum DebtFilter { all, esDeuda, porCobrar, pagado }

// Almacena el filtro seleccionado actualmente por el usuario
final debtFilterProvider = StateProvider<DebtFilter>((ref) {
  return DebtFilter.all;
});

// Muestra la lista final combinando el filtro de estado y la barra de búsqueda
final filteredDebtsProvider = Provider<List<Debt>>((ref) {
  // 1. Escuchamos la lista base desde el Notifier
  final allDebts = ref.watch(debtListProvider);

  // 2. Escuchamos el filtro activo
  final activeFilter = ref.watch(debtFilterProvider);

  // 3. Escuchamos la query de búsqueda
  final searchQuery = ref.watch(debtSearchQueryProvider).toLowerCase();

  // --- PRIMER PASO: Filtrar por tipo/estado ---
  List<Debt> filteredList;

  switch (activeFilter) {
    case DebtFilter.all:
      filteredList = allDebts;
      break;
    case DebtFilter.esDeuda:
      // Lo que tú debes y no has pagado aún
      filteredList = allDebts.where((d) => d.esDeuda && !d.pagado).toList();
      break;
    case DebtFilter.porCobrar:
      // Lo que te deben a ti y no te han pagado aún
      filteredList = allDebts.where((d) => !d.esDeuda && !d.pagado).toList();
      break;
    case DebtFilter.pagado:
      // Todo lo que ya esté marcado como pagado (sea deuda o préstamo)
      filteredList = allDebts.where((d) => d.pagado).toList();
      break;
  }

  // --- SEGUNDO PASO: Filtrar por texto de búsqueda (Si el usuario escribió algo) ---
  if (searchQuery.isNotEmpty) {
    filteredList = filteredList
        .where((d) => d.nombre.toLowerCase().contains(searchQuery))
        .toList();
  }

  return filteredList;
});
