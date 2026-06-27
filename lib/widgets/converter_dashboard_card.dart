import 'package:flutter/material.dart';
import 'package:the_finxup_app/screens/currency_converter_screen.dart';
import 'package:the_finxup_app/widgets/animated_rate_ticker.dart';

class ConverterDashboardCard extends StatelessWidget {
  const ConverterDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          color:
              theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24), // Bordes bien redondeados
          clipBehavior: Clip
              .antiAlias, // Necesario para que el InkWell no se salga de los bordes
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: InkWell(
            onTap: () {
              debugPrint('Navegando al conversor...');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencyConverterScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20), // Espaciado generoso interno
              child: Row(
                children: [
                  // Columna Izquierda: Textos y CTA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'EN VIVO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Conversor de\nMonedas',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Acceder',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Columna Derecha: El Ticker Gigante
                  const PremiumRateTicker(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
