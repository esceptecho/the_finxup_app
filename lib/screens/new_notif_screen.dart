import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/dismissed_notifications_notifier.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

// ==========================================
// 2. NUEVA PANTALLA: NewNotifScreen
// ==========================================

class NewNotifScreen extends ConsumerWidget {
  const NewNotifScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos la lista ya filtrada reactivamente
    final appNotifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: true,
        actions: [
          Positioned(
            child: Chip(
              label: Text('${appNotifications.length}', style: TextStyle(color: AppThemeHSL.backgroundDeep),),
              backgroundColor: Colors.teal[100],
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
                  // --- AQUÍ SE OBTIENEN DIRECTAMENTE SIN LISTVIEW.BUILDER ---
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

                        // Botón de acción directa para eliminar/descartar la notificación
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            // Pasas directamente el ID de la notificación que tienes en el ciclo 'for'
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
}
