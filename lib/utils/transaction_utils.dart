
import 'package:time_machine/time_machine.dart';

// Solución optimizada usando aritmética precisa para manejo de calendarios comerciales y reales
class TransactionUtilsTM {
  // Calcula el acumulado proyectado a 1 año fijo (método original)
  static double calculateHistoricalPreviewTM({
    required double amount,
    required DateTime startDate,
    required String recurrence,
  }) {
    if (amount <= 0) return 0.0;
    if (recurrence == 'Única vez') return amount;

    final startLocal = LocalDate.dateTime(startDate);
    final targetLocal = startLocal.add(Period(years: 1));

    int count = 0;
    final period = getPeriod(recurrence);
    if (period == null) return 0.0;

    LocalDate current = startLocal;

    while (current <= targetLocal) {
      count++;
      current = current.add(period);
    }

    return count * amount;
  }

  // NUEVO MÉTODO DELEGADO: Calcula dinámicamente cuántas ocurrencias han pasado hasta el día de hoy exacto
  static double calculateAccumulatedToNowTM({
    required double amount,
    required DateTime startDate,
    required String recurrence,
  }) {
    if (amount <= 0) return 0.0;
    if (recurrence == 'Única vez') return amount;

    final startLocal = LocalDate.dateTime(startDate);
    final targetLocal = LocalDate.dateTime(DateTime.now());

    // Si la transacción está programada a futuro, no ha devengado saldo real histórico
    if (startLocal > targetLocal) return 0.0;

    int count = 0;
    final period = getPeriod(recurrence);
    if (period == null) return 0.0;

    LocalDate current = startLocal;

    // Ejecuta las iteraciones sumando los períodos reales (contempla variaciones de meses y bisiestos)
    while (current <= targetLocal) {
      count++;
      current = current.add(period);
    }

    return count * amount;
  }

  // Retorna el período correspondiente mapeando la cadena de texto de la UI
  static Period? getPeriod(String recurrence) {
    switch (recurrence) {
      case 'Diario':
        return Period(days: 1);
      case 'Semanal':
        return Period(weeks: 1);
      case 'Mensual':
        return Period(months: 1);
      case 'Trimestral':
        return Period(months: 3);
      case 'Semestral':
        return Period(months: 6);
      case 'Anual':
        return Period(years: 1);
      default:
        return null;
    }
  }
}










// import 'package:time_machine/time_machine.dart';

// class TransactionUtilsTM {
//   // --- MÉTODO EXISTENTE ---
//   static double calculateHistoricalPreviewTM({
//     required double amount,
//     required DateTime startDate,
//     required String recurrence,
//   }) {
//     if (amount <= 0) return 0.0;
//     if (recurrence == 'Única vez') return amount;

//     final startLocal = LocalDate.dateTime(startDate);
//     final targetLocal = startLocal.add(Period(years: 1));

//     int count = 0;
//     final period = getPeriod(recurrence);
//     if (period == null) return 0.0;

//     LocalDate current = startLocal;

//     while (current <= targetLocal) {
//       count++;
//       current = current.add(period);
//     }

//     return count * amount;
//   }

//   // --- NUEVO MÉTODO: Calcula desde startDate hasta el día de hoy ---
//   static double calculateAccumulatedToNowTM({
//     required double amount,
//     required DateTime startDate,
//     required String recurrence,
//   }) {
//     if (amount <= 0) return 0.0;

//     final startLocal = LocalDate.dateTime(startDate);
//     // Definimos el límite superior como la fecha actual del sistema
//     final targetLocal = LocalDate.dateTime(DateTime.now());

//     // Validación por si la fecha de inicio es en el futuro
//     if (startLocal > targetLocal) return 0.0;
//     if (recurrence == 'Única vez') return amount;

//     int count = 0;
//     final period = getPeriod(recurrence);
//     if (period == null) return 0.0;

//     LocalDate current = startLocal;

//     // El bucle corre solo hasta llegar a la fecha de hoy
//     while (current <= targetLocal) {
//       count++;
//       current = current.add(period);
//     }

//     return count * amount;
//   }

//   // --- MÉTODO AUXILIAR PÚBLICO ---
//   static Period? getPeriod(String recurrence) {
//     switch (recurrence) {
//       case 'Diario':
//         return Period(days: 1);
//       case 'Semanal':
//         return Period(weeks: 1);
//       case 'Mensual':
//         return Period(months: 1);
//       case 'Trimestral':
//         return Period(months: 3);
//       case 'Semestral':
//         return Period(months: 6);
//       case 'Anual':
//         return Period(years: 1);
//       default:
//         return null;
//     }
//   }
// }
