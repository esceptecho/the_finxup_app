import 'package:hive_ce/hive_ce.dart';
import 'package:uuid/uuid.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 6)
class Debt {
  // 1. Añadimos defaultValue a los campos String no nulos
  @HiveField(0, defaultValue: '')
  String nombre;

  @HiveField(1, defaultValue: 0.0)
  double cantidad;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3, defaultValue: false)
  bool pagado;

  @HiveField(4, defaultValue: true)
  bool esDeuda;

  @HiveField(5, defaultValue: CurrencyType.usd)
  CurrencyType currencyType;

  @HiveField(6)
  DateTime? fechaVencimiento;

  @HiveField(7)
  double? montoPagado;

  @HiveField(8)
  String? descripcion;

  @HiveField(9)
  double? tasaInteres;

  @HiveField(10)
  String? entidad;

  @HiveField(11)
  List<DebtPayment>? pagosRealizados;

  @HiveField(12)
  String? categoria;

  @HiveField(13)
  int? numeroCuotas;

  // 2. FALTABA EL HIVEFIELD AQUÍ. Le asignamos el 19 para mantener el orden.
  @HiveField(19)
  int? cuotasPagadas;

  @HiveField(14)
  DateTime? fechaRecordatorio;

  @HiveField(15)
  RecurrenceType? recurrenceType;

  // 3. Añadimos defaultValue para evitar el crasheo de "Null is not a subtype of String"
  @HiveField(16, defaultValue: '')
  String id;

  Debt({
    this.nombre = '',
    this.cantidad = 0.0,
    DateTime? fecha,
    this.pagado = false,
    this.esDeuda = true,
    this.currencyType = CurrencyType.usd,
    this.fechaVencimiento,
    this.montoPagado,
    this.descripcion,
    this.tasaInteres,
    this.entidad,
    this.pagosRealizados,
    this.categoria,
    this.numeroCuotas,
    this.cuotasPagadas,
    this.fechaRecordatorio,
    this.recurrenceType,
    String? id,
  }) : fecha = fecha ?? DateTime.now(),
       // 4. CORRECCIÓN VITAL: Solo generar Uuid si NO viene un id por parámetro
       id = id ?? const Uuid().v4();

  double get montoRestante => cantidad - (montoPagado ?? 0);

  double get porcentajePagado =>
      cantidad > 0 ? ((montoPagado ?? 0) / cantidad * 100).clamp(0, 100) : 0;

  bool get isOverdue =>
      fechaVencimiento != null &&
      fechaVencimiento!.isBefore(DateTime.now()) &&
      !pagado &&
      montoRestante > 0;

  String get estadoDeuda {
    if (pagado) return 'Pagada';
    if (isOverdue) return 'Vencida';
    if (montoRestante < cantidad) return 'Pago parcial';
    return 'Pendiente';
  }

  String get tipoTransaccion => esDeuda ? 'Debo' : 'Me deben';

  Debt copyWith({
    String? nombre,
    double? cantidad,
    DateTime? fecha,
    bool? pagado,
    bool? esDeuda,
    CurrencyType? currencyType,
    DateTime? fechaVencimiento,
    double? montoPagado,
    String? descripcion,
    double? tasaInteres,
    String? entidad,
    List<DebtPayment>? pagosRealizados,
    String? categoria,
    int? numeroCuotas,
    int? cuotasPagadas,
    DateTime? fechaRecordatorio,
    RecurrenceType? recurrenceType,
    String? id,
  }) {
    return Debt(
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      fecha: fecha ?? this.fecha,
      pagado: pagado ?? this.pagado,
      esDeuda: esDeuda ?? this.esDeuda,
      currencyType: currencyType ?? this.currencyType,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      montoPagado: montoPagado ?? this.montoPagado,
      descripcion: descripcion ?? this.descripcion,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      entidad: entidad ?? this.entidad,
      pagosRealizados: pagosRealizados ?? this.pagosRealizados,
      categoria: categoria ?? this.categoria,
      numeroCuotas: numeroCuotas ?? this.numeroCuotas,
      cuotasPagadas: cuotasPagadas ?? this.cuotasPagadas,
      fechaRecordatorio: fechaRecordatorio ?? this.fechaRecordatorio,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      id: id ?? this.id, // 5. Faltaba incluir el ID al copiar
    );
  }
}

@HiveType(typeId: 17)
class DebtPayment {
  @HiveField(0)
  DateTime fecha;

  @HiveField(1)
  double monto;

  @HiveField(2)
  String? nota;

  DebtPayment({required this.fecha, required this.monto, this.nota});
}

@HiveType(typeId: 18)
enum RecurrenceType {
  @HiveField(0)
  oneTime,
  @HiveField(1)
  weekly,
  @HiveField(2)
  biweekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  quarterly,
  @HiveField(5)
  yearly,
}

@HiveType(typeId: 7)
enum CurrencyType {
  @HiveField(0)
  usd,
  @HiveField(1)
  eur,
  @HiveField(5)
  cop,
  @HiveField(2)
  mxn,
  @HiveField(3)
  gbp,
  @HiveField(4)
  jpy,
  @HiveField(6)
  ars,
  @HiveField(7)
  clp,
}

