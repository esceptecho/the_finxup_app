// lib/utils/share_service.dart
import 'package:share_plus/share_plus.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/utils/transaction_utils.dart';

class ShareService {
  /// Genera y comparte un resumen de la transacción
  static Future<void> shareTransaction({
    required Transaction transaction,
    double? valorHistorico,
  }) async {
    final String message = _buildShareMessage(
      transaction: transaction,
      valorHistorico: valorHistorico,
    );

    await Share.share(
      message,
      subject: 'Comprobante: ${transaction.description}',
    );
  }

  /// Comparte múltiples transacciones (resumen financiero)
  static Future<void> shareFinancialSummary({
    required double balance,
    required double income,
    required double expense,
    required double percentage,
  }) async {
    final String message =
        '''
📊 RESUMEN FINANCIERO - FinXup

💰 Balance: \$${balance.toStringAsFixed(2)}
📈 Ingresos: \$${income.toStringAsFixed(2)}
📉 Gastos: \$${expense.toStringAsFixed(2)}
📊 Porcentaje: ${percentage.toStringAsFixed(1)}%

Compartido desde FinXup App
''';

    await Share.share(message, subject: 'Mi Resumen Financiero - FinXup');
  }

  /// Construye el mensaje para una transacción individual
  static String _buildShareMessage({
    required Transaction transaction,
    double? valorHistorico,
  }) {
    final StringBuffer buffer = StringBuffer();

    // Tipo y emoji
    final bool isIncome = transaction.type == TransactionType.income;
    final String emoji = isIncome ? '💰' : '💸';
    final String tipo = isIncome ? 'INGRESO' : 'GASTO';

    buffer.writeln('$emoji $tipo - FinXup');
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📝 ${transaction.description}');
    buffer.writeln('💵 Monto: \$${transaction.amount.toStringAsFixed(2)}');

    // Fecha
    final String fecha = _formatDate(transaction.date);
    buffer.writeln('📅 Fecha: $fecha');

    // Categoría
    if (transaction.subCategory != null) {
      buffer.writeln('🏷️ Categoría: ${transaction.categoryDisplay}');
    }

    // Información de recurrencia
    if (transaction.recurrence != 'Única vez' &&
        transaction.recurrence.isNotEmpty) {
      buffer.writeln('🔄 Recurrencia: ${transaction.recurrence}');

      if (valorHistorico != null && valorHistorico > 0) {
        buffer.writeln(
          '📊 Acumulado a hoy: \$${valorHistorico.toStringAsFixed(2)}',
        );
      }

      // Proyección anual
      final ocurrenciasTotales = _getOcurrenciasTotales(transaction.recurrence);
      final proyeccionAnual = transaction.amount * ocurrenciasTotales;
      buffer.writeln(
        '🎯 Proyección anual: \$${proyeccionAnual.toStringAsFixed(2)}',
      );
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Compartido desde FinXup App 📱');

    return buffer.toString();
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static int _getOcurrenciasTotales(String recurrence) {
    switch (recurrence) {
      case 'Diario':
        return 365;
      case 'Semanal':
        return 52;
      case 'Mensual':
        return 12;
      case 'Trimestral':
        return 4;
      case 'Semestral':
        return 2;
      case 'Anual':
        return 1;
      default:
        return 1;
    }
  }
}
