import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/utils/notification_service.dart';

// Un Notifier simple que guarda un conjunto (Set) de IDs ocultos
// ==========================================
// 1. PROVIDERS (Lógica de Estado Oculto)
// ==========================================

// 1. Guarda los IDs de las notificaciones que el usuario borró
class DismissedNotificationsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void dismiss(String id) {
    state = {...state, id};
  }
}

final dismissedNotificationsProvider =
    NotifierProvider<DismissedNotificationsNotifier, Set<String>>(
      DismissedNotificationsNotifier.new,
    );

// 2. Combina los datos de la app, genera las alertas y filtra las eliminadas
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final bills = ref.watch(billListNotifierProvider).value ?? [];
  final transactions = ref.watch(transactionListNotifierProvider).value ?? [];
  final goals = ref.watch(goalListNotifierProvider).value ?? [];

  // Generamos todas
  final allNotifications = NotificationService.generate(
    bills,
    transactions,
    goals,
  );

  // Escuchamos las eliminadas
  final dismissedIds = ref.watch(dismissedNotificationsProvider);

  // Devolvemos solo las activas
  return allNotifications
      .where((notif) => !dismissedIds.contains(notif.id))
      .toList();
});
