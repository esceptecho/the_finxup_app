import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/providers/dismissed_notifications_notifier.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/utils/notification_service.dart';

// providers/notification_provider.dart

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  // 1. "Escuchamos" los otros providers. 
  // Cada vez que uno cambie, este bloque se ejecutará de nuevo.
  final billsAsync = ref.watch(billListNotifierProvider);
  final transactionsAsync = ref.watch(transactionListNotifierProvider);
  final goalsAsync = ref.watch(goalListNotifierProvider);

  final bills = billsAsync.value ?? [];
  final transactions = transactionsAsync.value ?? [];
  final goals = goalsAsync.value ?? [];

  // 1. Generamos todas las notificaciones
  final allNotifications = NotificationService.generate(
    bills,
    transactions,
    goals,
  );

  // 2. Escuchamos cuáles han sido descartadas
  final dismissedIds = ref.watch(dismissedNotificationsProvider);

  // 3. Filtramos para devolver solo las que NO han sido vistas
  return allNotifications
      .where((notif) => !dismissedIds.contains(notif.id))
      .toList();
});
