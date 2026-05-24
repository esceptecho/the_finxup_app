import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/providers/dismissed_notifications_notifier.dart';
import 'package:the_finxup_app/screens/new_notif_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
// import 'package:lottie/lottie.dart';

/// Define los tipos de notificaciones para aplicar colores e íconos automáticos.
enum BannerType { info, success, warning, error }

class ElegantBanner {
  /// Muestra un MaterialBanner moderno y unificado en toda la app.
  static void show(
    BuildContext context, {
    required final List<AppNotification> appNotifications,
    required WidgetRef ref,
    BannerType type = BannerType.info,
    IconData? customIcon,
    String? imagePath,
    // Lottie? lottie,
    Color? customBackgroundColor,
    Color? customTextColor,
    Duration duration = const Duration(seconds: 3),
    bool autoDismiss = true,
    VoidCallback? onBannerClose,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 1. Ocultar el banner actual antes de mostrar uno nuevo para evitar que se apilen.
    scaffoldMessenger.hideCurrentMaterialBanner();

    // 2. Determinar la paleta de colores según el tipo (si no se proporcionan colores personalizados).
    final Color bgColor = customBackgroundColor ?? _getBackgroundColor(type);
    final Color txtColor = customTextColor ?? _getTextColor(type);
    final IconData iconData = customIcon ?? _getIcon(type);

    // 3. Construir el banner
    final banner = MaterialBanner(
      elevation: 0, // Un look plano es más moderno
      backgroundColor: bgColor,
      dividerColor: Colors.transparent, // Quita la línea oscura por defecto
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      content: SizedBox(
        // 1. Definir una altura es vital para evitar errores de renderizado
        height: 150,
        child: ListView.builder(
          shrinkWrap: true, // Ayuda a que el ListView se ajuste al contenido
          itemCount: appNotifications.length,
          itemBuilder: (context, index) {
            final notif = appNotifications[index];
            return InkWell(
              onTap: () {
                // 1. Marcamos esta notificación específica como leída inmediatamente
                ref
                    .read(dismissedNotificationsProvider.notifier)
                    .dismiss(notif.id);
                print('🖥️ UI: Contando appNotifications.length in ElegantBanner: ${appNotifications.length}');
                print(
                  '🖥️ UI: Contando notif.id in ElegantBanner: ${notif.id}',
                );
                // 2. Ocultamos el banner de la pantalla
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

                // 3. Navegamos a la nueva pantalla unificada
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewNotifScreen(),
                    // AnimatedNotificationsDashboard(),
                  ),
                );
              },
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contenedor del ícono o imagen con un fondo sutil
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // color: Colors.white.withValues(alpha: 0.1), // Fondo blanco translúcido para resaltar el ícono
                          shape: BoxShape.circle,
                        ),
                        child: notif.imagePath != null
                            ? Image.asset(
                                notif.imagePath!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Icon(notif.icon, color: txtColor, size: 24),
                      ),
                  
                      // Contenedor de Texto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              notif.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: txtColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: TextStyle(
                                fontSize: 13,
                                color: txtColor.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: AppThemeHSL.divider.withValues(alpha: 0.2))
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        
        // Botón de cierre moderno
        IconButton.outlined(
          onPressed: () {
            scaffoldMessenger.hideCurrentMaterialBanner();
            if (onBannerClose != null) onBannerClose();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: txtColor.withValues(
              alpha: 0.2,
            ), // Botón translúcido
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Text(
            'Cerrar',
            style: TextStyle(
              fontSize: 13,
              color: txtColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    // 4. Mostrar el banner
    scaffoldMessenger.showMaterialBanner(banner);

    // 5. Lógica de auto-cierre
    if (autoDismiss) {
      Future.delayed(duration, () {
        if (context.mounted) {
          scaffoldMessenger.hideCurrentMaterialBanner();
        }
      });
    }
  }

  // --- MÉTODOS PRIVADOS PARA ESTILOS SEMÁNTICOS ---

  static Color _getBackgroundColor(BannerType type) {
    switch (type) {
      case BannerType.success:
        return Colors.teal[50]!;
      case BannerType.error:
        return Colors.red[50]!;
      case BannerType.warning:
        return Colors.orange[50]!;
      case BannerType.info:
        return Colors.blueGrey[50]!;
    }
  }

  static Color _getTextColor(BannerType type) {
    switch (type) {
      case BannerType.success:
        return Colors.teal[500]!;
      case BannerType.error:
        return Colors.red[900]!;
      case BannerType.warning:
        return Colors.orange[900]!;
      case BannerType.info:
        return Colors.blueGrey[900]!;
    }
  }

  static IconData _getIcon(BannerType type) {
    switch (type) {
      case BannerType.success:
        return Icons.check_circle_outline_rounded;
      case BannerType.error:
        return Icons.error_outline_rounded;
      case BannerType.warning:
        return Icons.warning_amber_rounded;
      case BannerType.info:
        return Icons.info_outline_rounded;
    }
  }
}


/* // Ejemplo de uso:
1. Mensaje de Información (Por defecto)

ElegantBanner.show(
  context,
  title: 'Nuevo movimiento',
  message: 'Agregar nuevo movimiento o factura',
);

2. Mensaje de Éxito (Colores e ícono en verde/teal automáticos)
ElegantBanner.show(
  context,
  title: '¡Listo!',
  message: 'Movimiento agregado exitosamente',
  type: BannerType.success,
);

3. Mensaje de Error (Colores e ícono en rojo automáticos)
ElegantBanner.show(
  context,
  title: 'Error de conexión',
  message: 'No se pudo guardar la factura. Revisa tu internet.',
  type: BannerType.error,
);

4. Totalmente personalizado (Con imagen y colores propios)
ElegantBanner.show(
  context,
  title: 'Nueva factura',
  message: 'Detalles del proveedor cargados',
  imagePath: 'assets/icons/invoice_icon.png',
  customBackgroundColor: Colors.purple[50],
  customTextColor: Colors.purple[900],
  autoDismiss: false, // Se quedará fijo hasta que el usuario pulse "Cerrar"
);  */

