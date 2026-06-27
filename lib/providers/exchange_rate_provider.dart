
// lib/providers/exchange_rate_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:the_finxup_app/models/exchange_rate_response.dart';
import '../services/exchange_rate_service.dart';
import '../services/cache_service.dart';

part 'exchange_rate_provider.g.dart';

@riverpod
class ExchangeRateNotifier extends _$ExchangeRateNotifier {
  late final ExchangeRateService _service;
  Map<String, double>? _cachedRates;

  @override
  Future<ExchangeRateState> build() async {
    debugPrint('🔄 ExchangeRateNotifier: Inicializando...');
    _service = ExchangeRateService();

    final cached = await CacheService.getCachedRates(
      maxAge: const Duration(hours: 12),
    );

    if (cached != null) {
      debugPrint('✅ Usando tasas en caché (edad: ${cached.ageFormatted})');
      _cachedRates = cached.rates;
      return ExchangeRateState.initial().copyWith(
        rates: cached.rates,
        lastUpdate: cached.timestamp,
      );
    }

    debugPrint('📡 Caché expirado o inexistente. Solicitando API...');
    return _fetchRatesFromApi('USD');
  }

  Future<ExchangeRateState> _fetchRatesFromApi(String baseCurrency) async {
    try {
      final rates = await _service.getLatestRates(baseCurrency);
      await CacheService.cacheRates(rates: rates, baseCurrency: baseCurrency);
      _cachedRates = rates;

      return ExchangeRateState.initial().copyWith(
        rates: rates,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error al obtener tasas: $e');
      if (_cachedRates != null) {
        debugPrint('⚠️ Usando caché expirado como respaldo');
        return ExchangeRateState.initial().copyWith(
          rates: _cachedRates,
          lastUpdate: DateTime.now(),
        );
      }
      rethrow;
    }
  }

  Future<void> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    // Guardamos el estado actual antes de pasar al estado de carga
    final previousState = state.value ?? ExchangeRateState.initial();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      if (_cachedRates != null) {
        debugPrint('🧮 Conversión local: $amount $from → $to');

        final result = _service.convertLocally(
          amount: amount,
          from: from,
          to: to,
          rates: _cachedRates!,
        );

        final response = ExchangeRateResponse(
          result: 'success',
          baseCode: from,
          targetCode: to,
          conversionRate: amount > 0 ? result / amount : 0.0,
          conversionResult: result,
          lastUpdate: DateTime.now(),
          nextUpdate: DateTime.now().add(const Duration(hours: 12)),
        );

        // SOLUCIÓN: Usamos copyWith sobre el estado anterior para NO perder los datos
        return previousState.copyWith(
          conversion: response,
          lastUpdate: previousState.lastUpdate ?? DateTime.now(),
        );
      }

      debugPrint('🌐 Conversión vía API: $amount $from → $to');
      final result = await _service.convertViaApi(
        amount: amount,
        from: from,
        to: to,
      );

      return previousState.copyWith(
        conversion: result,
        lastUpdate: DateTime.now(),
      );
    });
  }

  Future<void> refreshRates(String baseCurrency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRatesFromApi(baseCurrency));
  }
}

// ============ ESTADO DEL PROVIDER CORREGIDO ============
@immutable
class ExchangeRateState {
  final ExchangeRateResponse? conversion;
  final Map<String, double> rates;
  final List<SupportedCurrency> currencies;
  final DateTime? lastUpdate; // SOLUCIÓN: Agregada la propiedad a la clase

  const ExchangeRateState({
    this.conversion,
    this.rates = const {},
    this.currencies = const [],
    this.lastUpdate,
  });

  ExchangeRateState copyWith({
    ExchangeRateResponse? conversion,
    Map<String, double>? rates,
    List<SupportedCurrency>? currencies,
    required DateTime lastUpdate,
  }) {
    return ExchangeRateState(
      conversion: conversion ?? this.conversion,
      rates: rates ?? this.rates,
      currencies: currencies ?? this.currencies,
      lastUpdate: lastUpdate, // SOLUCIÓN: Asignación correcta
    );
  }

  factory ExchangeRateState.initial() {
    return ExchangeRateState(
      currencies: AppCurrencies.currencies,
      lastUpdate: DateTime.now(),
    );
  }
}














// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:the_finxup_app/models/exchange_rate_response.dart';
// import 'package:flutter/foundation.dart';
// import 'package:the_finxup_app/services/exchange_rate_service.dart';
// part 'exchange_rate_provider.g.dart'; // Se genera con build_runner


// // ============ PROVIDER RIVERPOD CON @riverpod ============

// @riverpod
// class ExchangeRateNotifier extends _$ExchangeRateNotifier {
//   late final ExchangeRateService _service;

//   @override
//   Future<ExchangeRateState> build() async {
//     debugPrint('🔄 ExchangeRateNotifier: Inicializando build()...');

//     _service = ExchangeRateService();

//     try {
//       debugPrint('📡 Solicitando tasas para USD...');
//       final rates = await _service.getLatestRates('USD');
//       debugPrint('✅ Tasas obtenidas: ${rates.length} monedas');
//       debugPrint('📊 Datos: $rates');

//       return ExchangeRateState.initial().copyWith(rates: rates);
//     } catch (e, stack) {
//       debugPrint('❌ Error en build(): $e');
//       debugPrint('📍 Stack: $stack');
//       rethrow;
//     }
//   }

//   Future<void> convertCurrency({
//     required double amount,
//     required String from,
//     required String to,
//   }) async {
//     state = const AsyncValue.loading();
//     debugPrint('🔄 Convirtiendo: $amount $from → $to');
//     state = await AsyncValue.guard(() async {
//       final result = await _service.convertCurrency(
//         amount: amount,
//         from: from,
//         to: to,
//       );
//       debugPrint('✅ Conversión exitosa: ${result.conversionResult}');
//       return ExchangeRateState(conversion: result);
//     });
//   }

//   Future<void> refreshRates(String baseCurrency) async {
//     debugPrint('🔄 Refrescando tasas para $baseCurrency');
//     state = const AsyncValue.loading();
    
//     state = await AsyncValue.guard(() async {
//       final rates = await _service.getLatestRates(baseCurrency);
//       debugPrint('✅ Tasas refrescadas: $rates');
//       return ExchangeRateState.initial().copyWith(rates: rates);
//     });
//   }
// }



