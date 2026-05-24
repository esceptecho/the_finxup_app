import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

// dart run build_runner build --delete-conflicting-outputs // regenerar los archivos .g.dart (los adaptadores de Hive)
// dart run build_runner watch --delete-conflicting-outputs // Modo "Observador"

// Importante: Esta línea es necesaria para que el generador de código funcione
part 'hive_transaction_model.g.dart';

const uuid = Uuid();

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense, // <--- EL PUNTO Y COMA ES VITAL AQUÍ
}

@HiveType(typeId: 1)
enum IncomeSubCategory {
  @HiveField(0)
  alimony,
  @HiveField(1)
  bonus,
  @HiveField(2)
  cashback,
  @HiveField(3)
  commission,
  @HiveField(4)
  dividend,
  @HiveField(5)
  freelance,
  @HiveField(6)
  gift,
  @HiveField(7)
  inheritance,
  @HiveField(8)
  interest,
  @HiveField(9)
  investment,
  @HiveField(10)
  others,
  @HiveField(11)
  overtime,
  @HiveField(12)
  pension,
  @HiveField(13)
  prize,
  @HiveField(14)
  refund,
  @HiveField(15)
  rental,
  @HiveField(16)
  rewards,
  @HiveField(17)
  royalties,
  @HiveField(18)
  salary,
  @HiveField(19)
  sales,
  @HiveField(20)
  taxReturns,
  @HiveField(21)
  tips,
}

@HiveType(typeId: 2)
enum ExpenseSubCategory {
  @HiveField(0)
  beauty,
  @HiveField(1)
  charity,
  @HiveField(2)
  clothing,
  @HiveField(3)
  coffee,
  @HiveField(4)
  delivery,
  @HiveField(5)
  education,
  @HiveField(6)
  electronics,
  @HiveField(7)
  entertainment,
  @HiveField(8)
  food,
  @HiveField(9)
  gifts,
  @HiveField(10)
  gym,
  @HiveField(11)
  health,
  @HiveField(12)
  homeImprovement,
  @HiveField(13)
  impulsive,
  @HiveField(14)
  insurance,
  @HiveField(15)
  interest,
  @HiveField(16)
  kids,
  @HiveField(17)
  leisure,
  @HiveField(18)
  offerings,
  @HiveField(19)
  online,
  @HiveField(20)
  others,
  @HiveField(21)
  parking,
  @HiveField(22)
  pets,
  @HiveField(23)
  rent,
  @HiveField(24)
  repairs,
  @HiveField(25)
  savings,
  @HiveField(26)
  services,
  @HiveField(27)
  shopping,
  @HiveField(28)
  snacks,
  @HiveField(29)
  subscription,
  @HiveField(30)
  taxes,
  @HiveField(31)
  tolls,
  @HiveField(32)
  transport,
  @HiveField(33)
  travel,
}

// En tu archivo del modelo Transaction
extension EnumParser on dynamic {
  String get cleanName {
    if (this == null) return "General";
    // Esto maneja tanto enums con .name como la limpieza de "SubCategory.food"
    return toString().split('.').last;
  }
}

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final TransactionType type;
  @HiveField(4)
  final dynamic subCategory;
  @HiveField(5, defaultValue: 58263)
  final int iconCodePoint;
  @HiveField(6)
  List<String> attachmentPaths;
  @HiveField(7)
  final DateTime date;
  @HiveField(8)
  final String recurrence;
  @HiveField(9)
  final double? recurrenceAmount;

  Transaction({
    String? id,
    required this.description,
    required this.amount,
    required this.type,
    this.subCategory,
    this.iconCodePoint = 58263, // Icons.help_outline por defecto
    this.attachmentPaths = const [],
    required this.date,
    this.recurrence = 'Única vez',
    this.recurrenceAmount = 0.0,
  }) : id = id ?? uuid.v4();

  // Conservamos copyWith porque sigue siendo útil para la UI
  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionType? type,
    dynamic subCategory,
    int? iconCodePoint,
    List<String>? attachmentPaths,
    DateTime? date,
    String? recurrence,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      subCategory: subCategory ?? this.subCategory,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      date: date ?? this.date,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  // Getter para usar en la UI: transaction.categoryDisplay
  String get categoryDisplay {
    if (subCategory == null) return "General";

    // Convertimos a String: "ExpenseSubCategory.food"
    String raw = subCategory.toString();

    // Si contiene un punto, tomamos lo último. Si no, el string tal cual.
    String name = raw.contains('.') ? raw.split('.').last : raw;

    // Capitalizamos: "Food"
    if (name.isEmpty) return "General";
    return name[0].toUpperCase() + name.substring(1);
  }
}

extension TransactionTypeExtension on TransactionType {
  // Retorna la lista correcta según el tipo
  List<Enum> get subCategories {
    switch (this) {
      case TransactionType.income:
        return IncomeSubCategory.values;
      case TransactionType.expense:
        return ExpenseSubCategory.values;
    }
  }

  // Opcional: Para mostrar texto amigable en el formulario
  String get displayName =>
      this == TransactionType.income ? 'Ingreso' : 'Gasto';
}

extension TransactionExtension on Transaction {
  // Retorna cuántas veces ha ocurrido la transacción hasta una fecha dada
  int occurrencesUntil(DateTime limitDate) {
    if (recurrence == 'Única vez') return 1;

    DateTime current = DateUtils.dateOnly(date);
    DateTime target = DateUtils.dateOnly(limitDate);

    if (current.isAfter(target)) return 0;

    int count = 0;
    while (current.isBefore(target) || current.isAtSameMomentAs(target)) {
      count++;
      if (recurrence == 'Diario') {
        current = current.add(const Duration(days: 1));
      } else if (recurrence == 'Semanal') {
        current = current.add(const Duration(days: 7));
      } else if (recurrence == 'Mensual') {
        current = DateTime(current.year, current.month + 1, current.day);
      } else {
        break;
      }
    }
    return count;
  }

  // Calcula el dinero total acumulado hasta hoy
  double get totalAccumulatedValue => occurrencesUntil(DateTime.now()) * amount;
}

final Map<dynamic, IconData> categoryIcons = {
  // --- IncomeSubCategory (Alphabetical) ---
  IncomeSubCategory.alimony: Icons.family_restroom,
  IncomeSubCategory.bonus: Icons.card_giftcard,
  IncomeSubCategory.cashback: Icons.percent,
  IncomeSubCategory.commission: Icons.trending_up,
  IncomeSubCategory.dividend: Icons.account_balance,
  IncomeSubCategory.freelance: Icons.laptop_mac,
  IncomeSubCategory.gift: Icons.redeem,
  IncomeSubCategory.inheritance: Icons.account_balance,
  IncomeSubCategory.interest: Icons.percent,
  IncomeSubCategory.investment: Icons.trending_up,
  IncomeSubCategory.others: Icons.more_horiz,
  IncomeSubCategory.overtime: Icons.access_time,
  IncomeSubCategory.pension: Icons.volunteer_activism,
  IncomeSubCategory.prize: Icons.emoji_events,
  IncomeSubCategory.refund: Icons.settings_backup_restore,
  IncomeSubCategory.rental: Icons.location_city,
  IncomeSubCategory.rewards: Icons.stars,
  IncomeSubCategory.royalties: Icons.music_note,
  IncomeSubCategory.salary: Icons.payments,
  IncomeSubCategory.sales: Icons.store,
  IncomeSubCategory.taxReturns: Icons.description, // Added missing icon
  IncomeSubCategory.tips: Icons.monetization_on,

  // --- ExpenseSubCategory (Alphabetical) ---
  ExpenseSubCategory.beauty: Icons.spa,
  ExpenseSubCategory.charity: Icons.volunteer_activism,
  ExpenseSubCategory.clothing: Icons.checkroom,
  ExpenseSubCategory.coffee: Icons.coffee,
  ExpenseSubCategory.delivery: Icons.delivery_dining,
  ExpenseSubCategory.education: Icons.school,
  ExpenseSubCategory.electronics: Icons.devices,
  ExpenseSubCategory.entertainment: Icons.confirmation_number,
  ExpenseSubCategory.food: Icons.restaurant,
  ExpenseSubCategory.gifts: Icons.featured_play_list,
  ExpenseSubCategory.gym: Icons.fitness_center,
  ExpenseSubCategory.health: Icons.medical_services,
  ExpenseSubCategory.homeImprovement: Icons.build,
  ExpenseSubCategory.impulsive: Icons.flash_on,
  ExpenseSubCategory.insurance: Icons.security,
  ExpenseSubCategory.interest: Icons.receipt_long,
  ExpenseSubCategory.kids: Icons.child_care,
  ExpenseSubCategory.leisure: Icons.theater_comedy,
  ExpenseSubCategory.offerings: Icons.church,
  ExpenseSubCategory.online: Icons.language,
  ExpenseSubCategory.others: Icons.category,
  ExpenseSubCategory.parking: Icons.local_parking,
  ExpenseSubCategory.pets: Icons.pets,
  ExpenseSubCategory.rent: Icons.home,
  ExpenseSubCategory.repairs: Icons.handyman,
  ExpenseSubCategory.savings: Icons.savings,
  ExpenseSubCategory.services: Icons.plumbing,
  ExpenseSubCategory.shopping: Icons.shopping_bag,
  ExpenseSubCategory.snacks: Icons.cookie,
  ExpenseSubCategory.subscription: Icons.subscriptions,
  ExpenseSubCategory.taxes: Icons.description,
  ExpenseSubCategory.tolls: Icons.toll,
  ExpenseSubCategory.transport: Icons.directions_car,
  ExpenseSubCategory.travel: Icons.flight_takeoff,
};
