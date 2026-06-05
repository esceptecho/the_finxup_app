import 'package:hive_ce/hive_ce.dart'; // <-- IMPORTANTE: Usa hive_ce_flutter

part 'debt_model.g.dart';

@HiveType(typeId: 6)
class Debt {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  double cantidad;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  bool pagado;

  @HiveField(4)
  bool esDeuda;

  @HiveField(5)
  CurrencyType currencyType;

  // Constructor modificado con valores iniciales por defecto para el generador
  Debt({
    this.nombre = '',
    this.cantidad = 0.0,
    DateTime? fecha,
    this.pagado = false,
    this.esDeuda = true,
    this.currencyType = CurrencyType.usd, // Valor por defecto
  }) : fecha = fecha ?? DateTime.now();

  String get tipoTransaccion => esDeuda ? 'Debo' : 'Me deben';

  // Copiar objeto para mantener la inmutabilidad en Riverpod
  Debt copyWith({
    String? nombre,
    double? cantidad,
    DateTime? fecha,
    bool? pagado,
    bool? esDeuda,
    CurrencyType? currencyType,
  }) {
    return Debt(
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      fecha: fecha ?? this.fecha,
      pagado: pagado ?? this.pagado,
      esDeuda: esDeuda ?? this.esDeuda,
      currencyType: currencyType ?? this.currencyType,
    );
  }
}


@HiveType(typeId: 7) // Asegúrate de que este ID sea único en tu app
enum CurrencyType {
  @HiveField(0) usd,
  @HiveField(1) eur,
  @HiveField(5) cop,
  @HiveField(2) mxn,
  @HiveField(3) gbp,
  @HiveField(4) jpy,
  @HiveField(6) ars,
  @HiveField(7) clp,
}

// Extensión para facilitar la visualización en la UI
extension CurrencyTypeExtension on CurrencyType {
  String get code => name.toUpperCase();

  String get symbol {
    switch (this) {
      case CurrencyType.usd:
      case CurrencyType.mxn:
      case CurrencyType.cop:
      case CurrencyType.ars:
      case CurrencyType.clp:
        return '\$';
      case CurrencyType.eur:
        return '€';
      case CurrencyType.gbp:
        return '£';
      case CurrencyType.jpy:
        return '¥';
    }
  }
}