import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/utils/notification_service.dart';

// Un Notifier simple que guarda un conjunto (Set) de IDs ocultos
// ==========================================
// 1. PROVIDERS (Lógica de Estado Oculto)
// ==========================================

class DismissedNotificationsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void dismiss(String id) {
    state = {...state, id}; // Agrega el ID al Set de ocultos
  }
}

final dismissedNotificationsProvider =
    NotifierProvider<DismissedNotificationsNotifier, Set<String>>(
      DismissedNotificationsNotifier.new,
    );

// Tu provider original modificado con el filtro
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final billsAsync = ref.watch(billListNotifierProvider);
  final transactionsAsync = ref.watch(transactionListNotifierProvider);
  final goalsAsync = ref.watch(goalListNotifierProvider);

  final bills = billsAsync.value ?? [];
  final transactions = transactionsAsync.value ?? [];
  final goals = goalsAsync.value ?? [];

  // Generamos todas las notificaciones desde tu servicio
  final allNotifications = NotificationService.generate(
    bills,
    transactions,
    goals,
  );

  // Escuchamos cuáles ya vio/descartó el usuario
  final dismissedIds = ref.watch(dismissedNotificationsProvider);

  // Filtramos: Solo se quedan las que NO estén en el Set de descartadas
  return allNotifications
      .where((notif) => !dismissedIds.contains(notif.id))
      .toList();
});
