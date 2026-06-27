import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/exchange_rate_response.dart';
import 'package:the_finxup_app/utils/date_formatter.dart';

class ConversionResult extends StatelessWidget {
  final ExchangeRateResponse conversion;
  final SupportedCurrency? toCurrency;

  const ConversionResult({
    super.key,
    required this.conversion,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'RESULTADO',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              toCurrency?.formatAmount(conversion.conversionResult) ??
                  conversion.conversionResult.toStringAsFixed(2),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '1 ${conversion.baseCode} = ${conversion.conversionRate.toStringAsFixed(4)} ${conversion.targetCode}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Actualizado: ${DateFormatter.formatDateTime(conversion.lastUpdate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
