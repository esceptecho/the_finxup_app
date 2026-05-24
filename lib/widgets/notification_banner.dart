import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/notification_model.dart';

class NotificationCarruselBanner {
  static void show(
    BuildContext context, {
    required List<NotificationModel> notifications,
    Duration duration = const Duration(seconds: 6),
    bool autoDismiss = true,
  }) {
    if (notifications.isEmpty) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.removeCurrentMaterialBanner();

    // Colores base para el tema oscuro
    const Color surfaceColor = Color(0xFF1A1A1A);
    const Color cardColor = Color(0xFF252525);

    final banner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: false,
      dividerColor: Colors.transparent,
      padding: EdgeInsets.zero,
      content: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 110,
            child: Row(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      // El color viene directamente de tu NotificationModel
                      final accentColor = item.color ?? Colors.blueAccent;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icono con diseño de "fuego" o resplandor
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                item.icon,
                                color: accentColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Textos
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.title.toUpperCase(),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Separador sutil y botón cerrar
                Container(width: 1, height: 40, color: Colors.white10),
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () =>
                      scaffoldMessenger.hideCurrentMaterialBanner(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [const SizedBox.shrink()],
    );

    scaffoldMessenger.showMaterialBanner(banner);

    if (autoDismiss) {
      Future.delayed(duration, () {
        if (context.mounted) scaffoldMessenger.hideCurrentMaterialBanner();
      });
    }
  }
}
