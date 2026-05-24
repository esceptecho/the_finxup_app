import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/app_notification.dart';
// Importa tu NotificationModel aquí

class NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: notification.color.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinea arriba si el texto es largo
        children: [
          CircleAvatar(
            // Un fondo un poco más fuerte para el ícono
            backgroundColor: const Color.fromARGB(63, 239, 108, 0), 
            child: Icon(notification.icon, color: Colors.white54 ), // notification.color
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .orange[800], //notification.color.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
