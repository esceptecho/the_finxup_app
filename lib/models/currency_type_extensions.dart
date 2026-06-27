// lib/models/currency_type_extensions.dart

import 'package:the_finxup_app/models/debt_model.dart';

extension CurrencyTypeExtension on CurrencyType {
  String get code {
    switch (this) {
      case CurrencyType.usd:
        return 'USD';
      case CurrencyType.eur:
        return 'EUR';
      case CurrencyType.gbp:
        return 'GBP';
      case CurrencyType.mxn:
        return 'MXN';
      case CurrencyType.cop:
        return 'COP';
      case CurrencyType.jpy:
        return 'JPY';
      case CurrencyType.ars:
        return 'ARS';
      case CurrencyType.clp:
        return 'CLP';
    }
  }

  String get symbol {
    switch (this) {
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

  String get flag {
    switch (this) {
      case CurrencyType.usd:
        return '🇺🇸';
      case CurrencyType.eur:
        return '🇪🇺';
      case CurrencyType.gbp:
        return '🇬🇧';
      case CurrencyType.mxn:
        return '🇲🇽';
      case CurrencyType.cop:
        return '🇨🇴';
      case CurrencyType.jpy:
        return '🇯🇵';
      case CurrencyType.ars:
        return '🇦🇷';
      case CurrencyType.clp:
        return '🇨🇱';
    }
  }

  String get fullName {
    switch (this) {
      case CurrencyType.usd:
        return 'Dólar Estadounidense';
      case CurrencyType.eur:
        return 'Euro';
      case CurrencyType.gbp:
        return 'Libra Esterlina';
      case CurrencyType.mxn:
        return 'Peso Mexicano';
      case CurrencyType.cop:
        return 'Peso Colombiano';
      case CurrencyType.jpy:
        return 'Yen Japonés';
      case CurrencyType.ars:
        return 'Peso Argentino';
      case CurrencyType.clp:
        return 'Peso Chileno';
    }
  }

  int get decimalDigits {
    switch (this) {
      case CurrencyType.cop:
      case CurrencyType.ars:
      case CurrencyType.clp:
        return 0; // Sin decimales
      default:
        return 2; // Dos decimales
    }
  }

  String formatAmount(double amount) {
    return '$symbol ${amount.toStringAsFixed(decimalDigits)}';
  }
}
