import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/exchange_rate_response.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class QuickRatesGrid extends StatelessWidget {
  final Map<String, double> rates;
  final String baseCurrency;

  const QuickRatesGrid({
    super.key,
    required this.rates,
    required this.baseCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (rates.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: .center,
          children: [
            Text(
              'Tasas Actuales (1 $baseCurrency)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: rates.length,
          itemBuilder: (context, index) {
            final code = rates.keys.elementAt(index);
            final rate = rates[code]!;
            final currency = AppCurrencies.getByCode(code);

            return RateCard(code: code, rate: rate, currency: currency);
          },
        ),
      ],
    );
  }
}

class RateCard extends StatelessWidget {
  final String code;
  final double rate;
  final SupportedCurrency? currency;

  const RateCard({super.key, 
    required this.code,
    required this.rate,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppThemeHSL.surfaceLight,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Hero(
          tag: currency!.flag,
          curve: Curves.elasticOut, // Efecto "resorte" al entrar
          reverseCurve: Curves.easeInOutCubic, // Transición suave al volver
          createRectTween: (begin, end) {
            // Controla cómo cambia el tamaño/posición (opcional)
            return RectTween(begin: begin, end: end);
          },
          flightShuttleBuilder:
              (context, animation, direction, fromContext, toContext) {
                // Construye un widget personalizado que "vuela"
                // Útil si el diseño cambia drásticamente
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: animation.value * 0.5 + 0.5, // Escala de 0.5 a 1.0
                      child: child,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            currency!.flag,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            code,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rate.toStringAsFixed(4),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppThemeHSL.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
          placeholderBuilder: (context, size, child) {
            // Muestra un widget mientras el Hero viaja
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.transparent,
              child: CircularProgressIndicator(),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: .min,
                children: [
                  Text(currency!.flag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    code,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                rate.toStringAsFixed(4),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppThemeHSL.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
