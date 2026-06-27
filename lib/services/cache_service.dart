import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _ratesKey = 'cached_exchange_rates';
  static const String _timestampKey = 'cached_rates_timestamp';
  static const String _baseCurrencyKey = 'cached_base_currency';

  /// Guarda las tasas de cambio en caché local
  static Future<void> cacheRates({
    required Map<String, double> rates,
    required String baseCurrency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ratesKey, json.encode(rates));
    await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
    await prefs.setString(_baseCurrencyKey, baseCurrency);
  }

  /// Obtiene las tasas de cambio del caché si no han expirado
  static Future<CachedRates?> getCachedRates({
    Duration maxAge = const Duration(hours: 12),
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final timestampStr = prefs.getString(_timestampKey);
    final ratesStr = prefs.getString(_ratesKey);
    final baseCurrency = prefs.getString(_baseCurrencyKey);

    if (timestampStr == null || ratesStr == null || baseCurrency == null) {
      return null;
    }

    final timestamp = DateTime.parse(timestampStr);
    final age = DateTime.now().difference(timestamp);

    // Verificar si el caché ha expirado
    if (age > maxAge) {
      await clearCache();
      return null;
    }

    final rates = Map<String, double>.from(
      json.decode(ratesStr) as Map<String, dynamic>,
    );

    return CachedRates(
      rates: rates,
      baseCurrency: baseCurrency,
      timestamp: timestamp,
      age: age,
    );
  }

  /// Limpia el caché
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ratesKey);
    await prefs.remove(_timestampKey);
    await prefs.remove(_baseCurrencyKey);
  }
}

class CachedRates {
  final Map<String, double> rates;
  final String baseCurrency;
  final DateTime timestamp;
  final Duration age;

  CachedRates({
    required this.rates,
    required this.baseCurrency,
    required this.timestamp,
    required this.age,
  });

  bool get isExpired => age > const Duration(hours: 12);

  String get ageFormatted {
    if (age.inMinutes < 60) return '${age.inMinutes} min';
    if (age.inHours < 24) return '${age.inHours} horas';
    return '${age.inDays} días';
  }
}
