import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_currency_converter_provider.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';

// Provider para obtener el monto convertido de una deuda específica
final debtConvertedAmountProvider = Provider.family<DebtConvertedInfo, String>((
  ref,
  debtId,
) {
  final debts = ref.watch(debtListProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final converter = ref.watch(currencyConverterProvider);

  final debt = debts.where((d) => d.id == debtId).firstOrNull;

  if (debt == null) {
    return DebtConvertedInfo(
      originalAmount: 0,
      convertedAmount: 0,
      originalCurrency: CurrencyType.usd,
      targetCurrency: selectedCurrency,
      exchangeRate: 0,
    );
  }

  final convertedAmount = converter.convert(
    amount: debt.montoRestante,
    from: debt.currencyType,
    to: selectedCurrency,
  );

  // Calcular la tasa de cambio efectiva
  final rate = debt.montoRestante > 0
      ? convertedAmount / debt.montoRestante
      : 0.0;

  return DebtConvertedInfo(
    originalAmount: debt.montoRestante,
    convertedAmount: convertedAmount,
    originalCurrency: debt.currencyType,
    targetCurrency: selectedCurrency,
    exchangeRate: rate,
  );
});

// Modelo para la información convertida
class DebtConvertedInfo {
  final double originalAmount;
  final double convertedAmount;
  final CurrencyType originalCurrency;
  final CurrencyType targetCurrency;
  final double exchangeRate;

  const DebtConvertedInfo({
    required this.originalAmount,
    required this.convertedAmount,
    required this.originalCurrency,
    required this.targetCurrency,
    required this.exchangeRate,
  });

  bool get needsConversion => originalCurrency != targetCurrency;
}
