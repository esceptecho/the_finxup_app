import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/providers/dismissed_notifications_notifier.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

// ==========================================
// 2. NUEVA PANTALLA: NewNotifScreen
// ==========================================

class NewNotifScreen extends ConsumerWidget {
  // 1. Agregamos el parámetro opcional al constructor
  final AppNotification? notification;

  const NewNotifScreen({super.key, this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. SI VIENE UNA NOTIFICACIÓN, CONSTUIMOS LA VISTA DE DETALLE
    if (notification != null) {
      return _buildDetailView(context, ref, notification!);
    }

    // 3. SI NO VIENE, MOSTRAMOS TU LISTA ORIGINAL
    final appNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: true,
        actions: [
          // Corrección: Eliminado 'Positioned' (no permitido aquí) y envuelto en Center
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                label: Text(
                  '${appNotifications.length}',
                  style: TextStyle(color: AppThemeHSL.backgroundDeep),
                ),
                backgroundColor: Colors.teal[100],
              ),
            ),
          ),
        ],
      ),
      body: appNotifications.isEmpty
          ? const Center(
              child: Text(
                '¡Estás al día! No hay notificaciones.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final notif in appNotifications) ...[
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: notif.imagePath != null
                            ? Image.asset(
                                notif.imagePath!,
                                width: 40,
                                height: 40,
                              )
                            : Icon(notif.icon, color: Colors.teal),
                        title: Text(
                          notif.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(notif.message),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            ref
                                .read(dismissedNotificationsProvider.notifier)
                                .dismiss(notif.id);
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  /// --- VISTA DE DETALLE PARA UNA NOTIFICACIÓN INDIVIDUAL ---
  Widget _buildDetailView(
    BuildContext context,
    WidgetRef ref,
    AppNotification notif,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Notificación'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80,),
            // Icono o Imagen grande
            Center(
              child: Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: notif.color.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(7)
                ),
                child: Icon(notif.icon, size: 80,),
                ),
            ),
            const SizedBox(height: 24),
            // Título
            Text(
              notif.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Mensaje completo
            Text(
              notif.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const Spacer(),
            // Botón de acción para marcar como leída desde el detalle
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Marcar como leída y volver',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                // 1. La marcamos como leída
                ref
                    .read(dismissedNotificationsProvider.notifier)
                    .dismiss(notif.id);
                // 2. Regresamos a la pantalla anterior
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
