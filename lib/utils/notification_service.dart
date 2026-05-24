import 'dart:math';

import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/models/assets_image_list.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class NotificationService {
  
  static List<AppNotification> generate(
    List<Bill> bills, 
    List<Transaction> transactions, 
    List<Goal> goals // <-- Ahora sí lo usaremos
  ) {
    List<AppNotification> notifications = [];
    final now = DateTime.now();
    String imagePath = assetPathList[Random().nextInt(assetPathList.length)];

    // --- REGLA 1: Facturas por vencer (Próximos 5 días) ---
    final limitDate = now.add(const Duration(days: 5));
    final upcomingBills = bills.where((b) => 
      !b.isPaid && 
      b.dueDate.isAfter(now.subtract(const Duration(days: 1))) && 
      b.dueDate.isBefore(limitDate)
    ).toList();

    for (var bill in upcomingBills) {
      
      notifications.add(AppNotification(
        id: 'bill-${bill.id}', // <--- ID CONSISTENTE 'bill-456'
        title: 'Factura Próxima',
        message: '${bill.title} vence pronto. Total: \$${bill.amount}',
        type: BannerType.warning,
        icon: Icons.calendar_month_rounded,
        height: 150.0,
        imagePath: imagePath,
      ));
    }

    // --- REGLA 2: Gastos Altos (> $500) ---
    final highExpenses = transactions.where((t) => t.type == TransactionType.expense && t.amount.abs() > 500).toList();
    for (var tx in highExpenses) {
      notifications.add(AppNotification(
        id: 'tx-${tx.id}', // <--- ID CONSISTENTE. Si tx.id es '123', el ID siempre será 'tx-123'
        title: 'Gasto Elevado',
        message: 'Detectamos un gasto de \$${tx.amount.abs()} en ${tx.description}.',
        type: BannerType.info,
        icon: Icons.trending_up_rounded,
        height: 140.0,
        imagePath: imagePath,
      ));
    }

    // --- REGLA 3: Metas de Ahorro (Progreso > 80%) ---
    for (var goal in goals) {
      final progress = goal.currentAmount / goal.targetAmount;
      if (progress >= 0.8 && progress < 1.0) {
        notifications.add(AppNotification(
          id: 'goal-${goal.id}', // <--- ID CONSISTENTE 'bill-456'
          title: '¡Casi lo logras!',
          message: 'Estás al ${(progress * 100).toStringAsFixed(0)}% de tu meta: ${goal.title}',
          type: BannerType.success,
          icon: Icons.auto_awesome_rounded,
          height: 160.0,
        ));
      }
    }

    // --- REGLA 4: Estado de cuenta limpio ---
    if (notifications.isEmpty) {
      notifications.add(AppNotification(
        id: uuid.v4(), // <--- ID CONSISTENTE 'bill-456'
        title: 'Todo en orden',
        message: 'No tienes alertas pendientes para hoy. ¡Buen trabajo!',
        type: BannerType.info,
        icon: Icons.info_outline,
        height: 40.0,
        imagePath: imagePath,
      ));
    }

    return notifications;
  }
}