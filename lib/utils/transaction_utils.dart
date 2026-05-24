import 'package:time_machine/time_machine.dart';

// La mejor solución usa time_machine para aritmética de fechas precisa:
class TransactionUtilsTM {
  static double calculateHistoricalPreviewTM({
    required double amount,
    required DateTime startDate,
    required String recurrence,
  }) {
    if (amount <= 0) return 0.0;
    if (recurrence == 'Única vez') return amount;

    final startLocal = LocalDate.dateTime(startDate);

    // SOLUCIÓN: Definir hasta dónde quieres calcular.
    // Si quieres ver cuánto se acumulará en 1 año desde que inicia:
    final targetLocal = startLocal.add(Period(years: 1));

    // Si prefieres que sea hasta el final del año actual:
    // final targetLocal = LocalDate(startLocal.year, 12, 31);

    int count = 0;
    final period = getPeriod(recurrence);
    if (period == null) return 0.0;

    LocalDate current = startLocal;

    // Ahora el bucle sí encontrará las recurrencias de Trimestre, Semestre, etc.
    while (current <= targetLocal) {
      count++;
      current = current.add(period);
    }

    return count * amount;
  }

  // CAMBIO CLAVE: Le quitamos el guion bajo (_) para hacerlo público
  // De esta forma, el provider puede usar esta misma lógica.
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

// class TransactionUtils {
//   static double calculateHistoricalPreview({
//     required double amount,
//     required DateTime startDate,
//     required String recurrence,
//   }) {
//     if (amount <= 0) return 0.0;
//     if (recurrence == 'Única vez') return amount;

//     DateTime current = DateUtils.dateOnly(startDate);
//     DateTime today = DateUtils.dateOnly(DateTime.now());
//     if (current.isAfter(today)) return 0.0;

//     int count = 0;
//     while (current.isBefore(today) || current.isAtSameMomentAs(today)) {
//       count++;
//       if (recurrence == 'Diario') {
//         current = current.add(const Duration(days: 1));
//       } else if (recurrence == 'Semanal') {
//         current = current.add(const Duration(days: 7));
//       } else if (recurrence == 'Mensual') {
//         current = DateTime(current.year, current.month + 1, current.day);
//       } else {
//         break;
//       }
//     }

//     // Fórmula matemática simple:
//     // $$Total = Valor \times Ocurrencias$$
//     return count * amount;
//   }
// }
