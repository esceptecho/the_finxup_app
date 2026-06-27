// lib/services/exchange_rate_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:the_finxup_app/models/exchange_rate_response.dart';

class ExchangeRateService {
  static const String _apiKey = '3e3a059e4b410cd91edfdeb9';
  final http.Client _client;

  ExchangeRateService({http.Client? client})
    : _client = client ?? http.Client();

  /// Obtiene tasas de cambio desde la API
  Future<Map<String, double>> getLatestRates(String baseCurrency) async {
    final uri = Uri.https(
      'v6.exchangerate-api.com',
      '/v6/$_apiKey/latest/$baseCurrency',
    );

    debugPrint('🌐 Fetching rates from API: $baseCurrency');

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] == 'success') {
          final allRates = Map<String, double>.from(
            (data['conversion_rates'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ),
          );

          // Filtrar solo las monedas que nos interesan
          final filtered = <String, double>{};
          for (final currency in AppCurrencies.currencies) {
            if (allRates.containsKey(currency.code)) {
              filtered[currency.code] = allRates[currency.code]!;
            }
          }

          return filtered;
        }
        throw ExchangeRateException(data['error-type'] ?? 'Error desconocido');
      }
      throw ExchangeRateException('HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error fetching rates: $e');
      rethrow;
    }
  }

  /// Conversión local usando tasas cacheadas (SIN LLAMADA HTTP)
  double convertLocally({
    required double amount,
    required String from,
    required String to,
    required Map<String, double> rates,
  }) {
    if (from == to) return amount;

    // Si tenemos tasas basadas en 'from/to'
    if (rates.containsKey(from) && rates.containsKey(to)) {
      // Multiplicar por la tasa destino y dividir por la tasa origen
      return amount * (rates[to]! / rates[from]!);
    }

    throw ExchangeRateException('No hay tasa disponible para $from → $to');
  }

  /// Conversión vía API (solo usar cuando no hay caché)
  Future<ExchangeRateResponse> convertViaApi({
    required double amount,
    required String from,
    required String to,
  }) async {
    final uri = Uri.https(
      'v6.exchangerate-api.com',
      '/v6/$_apiKey/pair/$from/$to/$amount',
    );

    debugPrint('🌐 API Conversion: $from → $to');

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          return ExchangeRateResponse.fromJson(data);
        }
        throw ExchangeRateException(data['error-type'] ?? 'Error desconocido');
      }
      throw ExchangeRateException('HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in API conversion: $e');
      rethrow;
    }
  }

  void dispose() => _client.close();
}

// ============ 1st ExchangeRateService ============
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:the_finxup_app/models/exchange_rate_response.dart';

// class ExchangeRateService {
//   static const String _apiKey =
//       '3e3a059e4b410cd91edfdeb9'; // ← Reemplaza con tu key real
  // static const String _baseUrl = 'https://v6.exchangerate-api.com/v6'; // Sin / al final
//   final http.Client _client;

//   ExchangeRateService({http.Client? client})
//     : _client = client ?? http.Client();

//   Future<ExchangeRateResponse> convertCurrency({
//     required double amount,
//     required String from,
//     required String to,
//   }) async {
//     // ✅ CORRECTO - Construir URL con Uri.https
//     final uri = Uri.https(
//       'v6.exchangerate-api.com',
//       '/v6/$_apiKey/pair/$from/$to/$amount',
//     );

//     debugPrint('🌐 URL: $uri');

//     try {
//       final response = await _client
//           .get(uri)
//           .timeout(const Duration(seconds: 10));

//       debugPrint('📥 Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['result'] == 'success') {
//           debugPrint('✅ Conversión exitosa');
//           return ExchangeRateResponse.fromJson(data);
//         }
//         throw ExchangeRateException(data['error-type'] ?? 'Error desconocido');
//       }
//       throw ExchangeRateException('HTTP ${response.statusCode}');
//     } catch (e) {
//       debugPrint('❌ Error: $e');
//       rethrow;
//     }
//   }

//   Future<Map<String, double>> getLatestRates(String baseCurrency) async {
//     // ✅ CORRECTO - Usar Uri.https para evitar errores de formato
//     final uri = Uri.https(
//       'v6.exchangerate-api.com',
//       '/v6/$_apiKey/latest/$baseCurrency',
//     );

//     debugPrint('🌐 URL: $uri');

//     try {
//       final response = await _client
//           .get(uri)
//           .timeout(const Duration(seconds: 10));

//       debugPrint('📥 Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint('📊 API Result: ${data['result']}');

//         if (data['result'] == 'success') {
//           final allRates = Map<String, double>.from(
//             (data['conversion_rates'] as Map<String, dynamic>).map(
//               (key, value) => MapEntry(key, (value as num).toDouble()),
//             ),
//           );

//           // Filtrar solo las 6 monedas
//           final filtered = <String, double>{};
//           for (final currency in AppCurrencies.currencies) {
//             if (allRates.containsKey(currency.code)) {
//               filtered[currency.code] = allRates[currency.code]!;
//             } else {
//               debugPrint('⚠️ Moneda no encontrada: ${currency.code}');
//             }
//           }

//           debugPrint('✅ Tasas filtradas: $filtered');
//           return filtered;
//         }

//         throw ExchangeRateException(data['error-type'] ?? 'Error desconocido');
//       }

//       throw ExchangeRateException('HTTP ${response.statusCode}');
//     } on http.ClientException catch (e) {
//       debugPrint('❌ Error de conexión: $e');
//       throw ExchangeRateException('Sin conexión a internet');
//     } catch (e) {
//       debugPrint('❌ Error inesperado: $e');
//       rethrow;
//     }
//   }

//   void dispose() => _client.close();
// }
