import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/exchange_rate_response.dart';
import 'package:the_finxup_app/providers/exchange_rate_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/common/error_view.dart';
import 'package:the_finxup_app/widgets/converter/converter_header.dart';
import 'package:the_finxup_app/widgets/converter/converter_card.dart';
import 'package:the_finxup_app/widgets/converter/conversion_result.dart';
import 'package:the_finxup_app/widgets/converter/quick_rates_grid.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends ConsumerState<CurrencyConverterScreen> {
  final _amountController = TextEditingController(text: '1.00');
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _performConversion();
  }

  void _performConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > 0) {
      ref
          .read(exchangeRateProvider.notifier)
          .convertCurrency(
            amount: amount,
            from: _fromCurrency,
            to: _toCurrency,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exchangeRateAsync = ref.watch(exchangeRateProvider);

    return Scaffold(
      backgroundColor: AppThemeHSL.background,
      appBar: AppBar(
        backgroundColor: AppThemeHSL.background,
        title: const Text('Conversor de Monedas'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(exchangeRateProvider.notifier)
                  .refreshRates(_fromCurrency);
            },
          ),
        ],
      ),
      body: exchangeRateAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando tasas de cambio...'),
            ],
          ),
        ),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () {
            ref.read(exchangeRateProvider.notifier).refreshRates(_fromCurrency);
          },
        ),
        data: (state) => _buildConverterContent(context, state),
      ),
    );
  }

  Widget _buildConverterContent(BuildContext context, ExchangeRateState state) {
    final fromCurrencyData = AppCurrencies.getByCode(_fromCurrency);
    final toCurrencyData = AppCurrencies.getByCode(_toCurrency);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ConverterHeader(),
          const SizedBox(height: 24),
          ConverterCard(
            fromCurrency: _fromCurrency,
            toCurrency: _toCurrency,
            fromCurrencyData: fromCurrencyData,
            toCurrencyData: toCurrencyData,
            state: state,
            amountController: _amountController,
            onSwapCurrencies: _swapCurrencies,
            onPerformConversion: _performConversion,
            onFromCurrencyChanged: (code) {
              setState(() => _fromCurrency = code!);
              _performConversion();
            },
            onToCurrencyChanged: (code) {
              setState(() => _toCurrency = code!);
              _performConversion();
            },
          ),
          const SizedBox(height: 24),
          if (state.conversion != null) ...[
            ConversionResult(
              conversion: state.conversion!,
              toCurrency: toCurrencyData,
            ),
            const SizedBox(height: 24),
          ],
          QuickRatesGrid(rates: state.rates, baseCurrency: _fromCurrency),
        ],
      ),
    );
  }
}
