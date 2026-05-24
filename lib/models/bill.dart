import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'bill.g.dart';

const uuid = Uuid();

@HiveType(typeId: 4)
class Bill extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final bool isPaid;

  @HiveField(5)
  final String recurrence; // 'Diario', 'Semanal', etc.
  @HiveField(6)
  final bool hasReminder;

  Bill({
    String? id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false, // Es mejor inicializarlo
    this.recurrence = 'Única vez',
    this.hasReminder = true,
  }) : id = id ?? uuid.v4(); // Genera un ID único si no se proporciona

  Bill copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? recurrence,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      recurrence: recurrence ?? this.recurrence,
    );
  }
}


// class Bill {
//   final String id;
//   final String title;
//   final double amount;
//   final DateTime dueDate;
//   bool? isPaid;

//   Bill({
//     required this.id,
//     required this.title,
//     required this.amount,
//     required this.dueDate,
//     this.isPaid,
//   });
// }