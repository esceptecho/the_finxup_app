// providers/exchange_rate_provider.dart

import 'package:flutter/foundation.dart';

// ============ MODELOS ============

@immutable
class ExchangeRateResponse {
  final String result;
  final String baseCode;
  final String targetCode;
  final double conversionRate;
  final double conversionResult;
  final DateTime lastUpdate;
  final DateTime nextUpdate;

  const ExchangeRateResponse({
    required this.result,
    required this.baseCode,
    required this.targetCode,
    required this.conversionRate,
    required this.conversionResult,
    required this.lastUpdate,
    required this.nextUpdate,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      result: json['result'] ?? '',
      baseCode: json['base_code'] ?? '',
      targetCode: json['target_code'] ?? '',
      conversionRate: (json['conversion_rate'] ?? 0).toDouble(),
      conversionResult: (json['conversion_result'] ?? 0).toDouble(),
      lastUpdate:
          DateTime.tryParse(json['time_last_update_utc'] ?? '') ??
          DateTime.now(),
      nextUpdate:
          DateTime.tryParse(json['time_next_update_utc'] ?? '') ??
          DateTime.now(),
    );
  }
}

@immutable
class SupportedCurrency {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final int decimalDigits;

  const SupportedCurrency({
    required this.code,
    required this.name,
    this.symbol = '',
    this.flag = '',
    this.decimalDigits = 2,
  });

  String formatAmount(double amount) {
    if (decimalDigits == 0) {
      return '$symbol ${amount.toStringAsFixed(0)}';
    }
    return '$symbol ${amount.toStringAsFixed(decimalDigits)}';
  }
}

// ============ MONEDAS PREDEFINIDAS (CONSTANTE) ============

class AppCurrencies {
  static const List<SupportedCurrency> currencies = [
    SupportedCurrency(
      code: 'USD',
      name: 'Dólar EE.UU.',
      symbol: '\$',
      flag: '🇺🇸',
      decimalDigits: 2,
    ),
    SupportedCurrency(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      flag: '🇪🇺',
      decimalDigits: 2,
    ),
    SupportedCurrency(
      code: 'CNY',
      name: 'Yuan Chino',
      symbol: '¥',
      flag: '🇨🇳',
      decimalDigits: 2,
    ),
    SupportedCurrency(
      code: 'COP',
      name: 'Peso Colombiano',
      symbol: '\$',
      flag: '🇨🇴',
      decimalDigits: 0,
    ),
    SupportedCurrency(
      code: 'GBP',
      name: 'Libra Esterlina',
      symbol: '£',
      flag: '🇬🇧',
      decimalDigits: 2,
    ),
    SupportedCurrency(
      code: 'MXN',
      name: 'Peso Mexicano',
      symbol: '\$',
      flag: '🇲🇽',
      decimalDigits: 2,
    ),
  ];

  static SupportedCurrency? getByCode(String code) {
    try {
      return currencies.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}

// ============ ESTADO ============
// movido al archivo del provider


// ============ EXCEPCIÓN ============

class ExchangeRateException implements Exception {
  final String message;
  const ExchangeRateException(this.message);
  @override
  String toString() => 'ExchangeRateException: $message';
}
