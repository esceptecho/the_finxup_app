import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/exchange_rate_provider.dart';

// Provider que expone las tasas de cambio como un Map simple
final exchangeRatesMapProvider = Provider<Map<String, double>>((ref) {
  final exchangeState = ref.watch(exchangeRateProvider);

  return exchangeState.when(
    data: (state) => state.rates,
    loading: () => const {},
    error: (_, _) => const {},
  );
});

// Provider para el conversor de monedas
final currencyConverterProvider = Provider<CurrencyConverter>((ref) {
  final rates = ref.watch(exchangeRatesMapProvider);
  return CurrencyConverter(rates: rates);
});

// Clase helper para conversiones
class CurrencyConverter {
  final Map<String, double> rates;

  // Tasas de conversión fijas como respaldo (actualizadas manualmente)
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.88,
    'GBP': 0.76,
    'MXN': 17.5,
    'COP': 3500.0,
    'CNY': 6.81,
    'JPY': 149.5,
    'ARS': 850.0,
    'CLP': 900.0,
  };

  CurrencyConverter({required this.rates});

  /// Convierte un monto de una moneda origen a una moneda destino
  double convert({
    required double amount,
    required CurrencyType from,
    required CurrencyType to,
  }) {
    if (from == to) return amount;

    final fromCode = from.name.toUpperCase();
    final toCode = to.name.toUpperCase();

    // Usar tasas disponibles (API o caché), con respaldo fijo
    final effectiveRates = rates.isNotEmpty ? rates : _fallbackRates;

    // Si no tenemos las tasas necesarias, retornar el monto original
    if (!effectiveRates.containsKey(fromCode) ||
        !effectiveRates.containsKey(toCode)) {
      return amount;
    }

    // Convertir a USD primero (moneda base), luego a la moneda destino
    final amountInUSD = amount / effectiveRates[fromCode]!;
    final convertedAmount = amountInUSD * effectiveRates[toCode]!;

    return convertedAmount;
  }

  /// Convierte una lista de deudas a una moneda específica
  Map<String, double> convertDebtsToCurrency({
    required List<Debt> debts,
    required CurrencyType targetCurrency,
    bool onlyUnpaid = true,
    bool onlyDebts = true,
  }) {
    double total = 0;
    int count = 0;

    for (final debt in debts) {
      // Aplicar filtros
      if (onlyUnpaid && debt.pagado) continue;
      if (onlyDebts && !debt.esDeuda) continue;
      if (!onlyDebts && debt.esDeuda) continue;

      final convertedAmount = convert(
        amount: debt.montoRestante,
        from: debt.currencyType,
        to: targetCurrency,
      );

      total += convertedAmount;
      count++;
    }

    return {'total': total, 'count': count.toDouble()};
  }

  /// Obtiene un resumen completo de deudas en la moneda seleccionada
  DebtCurrencySummary getDebtSummary({
    required List<Debt> debts,
    required CurrencyType targetCurrency,
  }) {
    double totalDeudas = 0;
    double totalPrestamos = 0;
    double totalPagado = 0;
    int countDeudas = 0;
    int countPrestamos = 0;
    int countPagadas = 0;
    int countVencidas = 0;
    int countTotal = 0;

    for (final debt in debts) {
      if (!debt.pagado) {
        final convertedAmount = convert(
          amount: debt.montoRestante,
          from: debt.currencyType,
          to: targetCurrency,
        );

        if (debt.esDeuda) {
          totalDeudas += convertedAmount;
          countDeudas++;
        } else {
          totalPrestamos += convertedAmount;
          countPrestamos++;
        }

        if (debt.isOverdue) countVencidas++;
      } else {
        // Usar el monto realmente pagado, no el total de la deuda
        final convertedPagado = convert(
          amount:
              debt.montoPagado ??
              debt.cantidad, // Si no hay montoPagado, usar el total
          from: debt.currencyType,
          to: targetCurrency,
        );

        totalPagado += convertedPagado; // ← AHORA SÍ SE USA
        countPagadas++;
      }

      countTotal++;
    }

    return DebtCurrencySummary(
      targetCurrency: targetCurrency,
      totalDeudas: totalDeudas,
      totalPrestamos: totalPrestamos,
      totalPagado: totalPagado,
      balance: totalPrestamos - totalDeudas,
      countDeudas: countDeudas,
      countPrestamos: countPrestamos,
      countPagadas: countPagadas,
      countVencidas: countVencidas,
      countTotal: countTotal,
    );
  }
}

// Modelo para el resumen de deudas en una moneda
class DebtCurrencySummary {
  final CurrencyType targetCurrency;
  final double totalDeudas;
  final double totalPrestamos;
  final double totalPagado;
  final double balance;
  final int countDeudas;
  final int countPrestamos;
  final int countPagadas;
  final int countVencidas;
  final int countTotal;

  const DebtCurrencySummary({
    required this.targetCurrency,
    required this.totalDeudas,
    required this.totalPrestamos,
    required this.totalPagado,
    required this.balance,
    required this.countDeudas,
    required this.countPrestamos,
    required this.countPagadas,
    required this.countVencidas,
    required this.countTotal,
  });

  String formatAmount(double amount) {
    final symbol = _getCurrencySymbol(targetCurrency);
    if (targetCurrency == CurrencyType.cop ||
        targetCurrency == CurrencyType.ars ||
        targetCurrency == CurrencyType.clp) {
      return '$symbol ${amount.toStringAsFixed(0)}';
    }
    return '$symbol ${amount.toStringAsFixed(2)}';
  }

  String _getCurrencySymbol(CurrencyType currency) {
    switch (currency) {
      case CurrencyType.usd:
        return '\$';
      case CurrencyType.eur:
        return '€';
      case CurrencyType.gbp:
        return '£';
      case CurrencyType.mxn:
        return '\$';
      case CurrencyType.cop:
        return '\$';
      case CurrencyType.jpy:
        return '¥';
      case CurrencyType.ars:
        return '\$';
      case CurrencyType.clp:
        return '\$';
    }
  }
}
