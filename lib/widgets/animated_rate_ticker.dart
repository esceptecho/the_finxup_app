import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/exchange_rate_response.dart';
import 'package:the_finxup_app/providers/exchange_rate_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class PremiumRateTicker extends ConsumerStatefulWidget {
  const PremiumRateTicker({super.key});

  @override
  ConsumerState<PremiumRateTicker> createState() => _PremiumRateTickerState();
}

class _PremiumRateTickerState extends ConsumerState<PremiumRateTicker> {
  int _currentIndex = 0;
  Timer? _timer;
  int _lastRatesLength = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int ratesLength) {
    _timer?.cancel();
    if (ratesLength == 0) return;

    if (_lastRatesLength != ratesLength) {
      _currentIndex = 0;
      _lastRatesLength = ratesLength;
    }

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % ratesLength;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exchangeRateAsync = ref.watch(exchangeRateProvider);

    return Container(
      // Aumentamos el tamaño significativamente para darle relevancia
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppThemeHSL.surfaceLighter,
        borderRadius: BorderRadius.circular(7),
        // border: Border.all(
        //   color: AppThemeHSL.accentGold.withValues(alpha: 0.2),
        //   width: 1.5,
        // ),
      ),
      child: exchangeRateAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
        error: (error, stack) => Icon(
          Icons.error_outline_rounded,
          color: theme.colorScheme.error,
          size: 32,
        ),
        data: (state) {
          final rates = state.rates;

          if (rates.isEmpty) {
            return const Icon(Icons.money_off_rounded, size: 32);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_timer == null || _lastRatesLength != rates.length) {
              _startTimer(rates.length);
            }
          });

          final code = rates.keys.elementAt(_currentIndex);
          final rate = rates[code]!;
          final currency = AppCurrencies.getByCode(code);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Hero(
  tag: currency!.flag,
  curve: Curves.elasticOut,
  reverseCurve: Curves.easeInOutCubic,
  createRectTween: (begin, end) {
                  return MaterialRectArcTween(begin: begin, end: end);
                },
  flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
    // Widget personalizado durante el vuelo
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value * 0.5 + 0.5, // Escala de 0.5 a 1.0
          child: child,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currency.flag,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                code,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            rate.toStringAsFixed(2),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  },
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currency.flag,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            code,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        rate.toStringAsFixed(2),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  ),
),
            ),
          );
        },
      ),
    );
  }
}
