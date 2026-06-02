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

  // Constructor modificado con valores iniciales por defecto para el generador
  Debt({
    this.nombre = '',
    this.cantidad = 0.0,
    DateTime? fecha,
    this.pagado = false,
    this.esDeuda = true,
  }) : fecha = fecha ?? DateTime.now();

  String get tipoTransaccion => esDeuda ? 'Debo' : 'Me deben';

  // Copiar objeto para mantener la inmutabilidad en Riverpod
  Debt copyWith({
    String? nombre,
    double? cantidad,
    DateTime? fecha,
    bool? pagado,
    bool? esDeuda,
  }) {
    return Debt(
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      fecha: fecha ?? this.fecha,
      pagado: pagado ?? this.pagado,
      esDeuda: esDeuda ?? this.esDeuda,
    );
  }
}
