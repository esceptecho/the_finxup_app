import 'package:hive_ce_flutter/hive_flutter.dart';

part 'goal.g.dart'; // Nombre del archivo generado

@HiveType(typeId: 5)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final double currentAmount; 

  @HiveField(4, defaultValue: '🎯') 
  final String emoji;

  @HiveField(5)
  final DateTime targetDate;

  

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.emoji = "🎯",
    required this.targetDate, // O dale un valor por defecto aquí
    
    
  });

  Goal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? emoji,
    
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      emoji: emoji ?? this.emoji, 
      targetDate: targetDate,
      
      
    );
  }

    // Calcula el porcentaje (0.0 a 1.0)
  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  String get progressText => "${(progress * 100).toInt()}%";
}

