import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/exchange_rate_response.dart';
import 'package:the_finxup_app/providers/exchange_rate_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/converter/currency_selector.dart';

class ConverterCard extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final SupportedCurrency? fromCurrencyData;
  final SupportedCurrency? toCurrencyData;
  final ExchangeRateState state;
  final TextEditingController amountController;
  final VoidCallback onSwapCurrencies;
  final VoidCallback onPerformConversion;
  final ValueChanged<String?> onFromCurrencyChanged;
  final ValueChanged<String?> onToCurrencyChanged;

  const ConverterCard({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromCurrencyData,
    required this.toCurrencyData,
    required this.state,
    required this.amountController,
    required this.onSwapCurrencies,
    required this.onPerformConversion,
    required this.onFromCurrencyChanged,
    required this.onToCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Usamos el color del tema para adaptabilidad automática
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0, // Un diseño flat con un borde sutil suele verse más moderno
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto estilizado
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign:
                  TextAlign.start, // Alineación izquierda para mejor lectura
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: 'Cantidad a convertir',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                // Icono dinámico o neutral
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    right: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppThemeHSL.primary,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.payments_rounded,
                      color: AppThemeHSL.textPrimary,
                    ),
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 0.5,
                  ),
                ),
              ),
              onChanged: (_) => onPerformConversion(),
            ),
            const SizedBox(height: 24),
            // Sección de selección de monedas integrada
            CurrencySelector(
              label: 'De',
              currency: fromCurrencyData,
              selectedCode: fromCurrency,
              onChanged: onFromCurrencyChanged,
            ),

            // Botón de swap flotante o intermedio más sutil
            Padding(
              padding: const EdgeInsets.only(top: 36, bottom: 18),
              child: Center(
                child: Material(
                  color: theme.colorScheme.primaryContainer,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(
                      Icons
                          .swap_vert_rounded, // Un icono más moderno y redondeado
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: onSwapCurrencies,
                    tooltip: 'Intercambiar monedas',
                  ),
                ),
              ),
            ),

            CurrencySelector(
              label: 'A',
              currency: toCurrencyData,
              selectedCode: toCurrency,
              onChanged: onToCurrencyChanged,
            ),

            

            
          ],
        ),
      ),
    );
  }
}
