
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';

class DebtSummaryCard extends ConsumerWidget {
  const DebtSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(debtCurrencySummaryProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selector de moneda
            DropdownButton<CurrencyType>(
              value: selectedCurrency,
              onChanged: (currency) {
                ref.read(selectedCurrencyProvider.notifier).state = currency!;
              },
              items: CurrencyType.values.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency.name.toUpperCase()),
                );
              }).toList(),
            ),
            const Divider(),
            // Totales en la moneda seleccionada
            _buildAmountRow(
              context,
              'Deudas',
              summary.totalDeudas,
              Colors.red,
              summary.targetCurrency,
            ),
            _buildAmountRow(
              context,
              'Préstamos',
              summary.totalPrestamos,
              Colors.green,
              summary.targetCurrency,
            ),
            _buildAmountRow(
              context,
              'Balance',
              summary.balance,
              summary.balance >= 0 ? Colors.green : Colors.red,
              summary.targetCurrency,
            ),
            const Divider(),
            Text(
              '${summary.countDeudas} deudas • ${summary.countVencidas} vencidas',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    double amount,
    Color color,
    CurrencyType currency,
  ) {
    final theme = Theme.of(context);
    final symbol = _getSymbol(currency);
    final formatted =
        currency == CurrencyType.cop ||
            currency == CurrencyType.ars ||
            currency == CurrencyType.clp
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          Text(
            '$symbol $formatted',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getSymbol(CurrencyType currency) {
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
