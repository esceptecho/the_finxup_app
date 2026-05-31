import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/widgets/notification_card.dart';
// import 'package:lottie/lottie.dart';

/// Define los tipos de notificaciones para aplicar colores e íconos automáticos.
enum BannerType { info, success, warning, error }

class ElegantBanner {
  static void show(
    BuildContext context, {
    required final List<AppNotification> appNotifications,
    required WidgetRef ref,
    BannerType type = BannerType.info,
    IconData? customIcon,
    String? imagePath,
    Color? customBackgroundColor,
    Color? customTextColor,
    Duration duration = const Duration(seconds: 5),
    bool autoDismiss = true,
    VoidCallback? onBannerClose,
  }) {
    if (appNotifications.isEmpty) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentMaterialBanner();

    final Color bgColor = customBackgroundColor ?? _getBackgroundColor(type);
    final Color txtColor = customTextColor ?? _getTextColor(type);

    final banner = MaterialBanner(
      elevation: 0,
      backgroundColor: bgColor,
      dividerColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12),
      content: SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: appNotifications.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final notif = appNotifications[index];

            // Invocamos nuestra tarjeta inteligente
            return NotificationCard(
              notif: notif,
              txtColor: txtColor,
              ref: ref,
              totalNotifications: appNotifications.length,
            );
          },
        ),
      ),
      actions: const [SizedBox.shrink()],
    );

    scaffoldMessenger.showMaterialBanner(banner);

    if (autoDismiss) {
      Future.delayed(duration, () {
        if (context.mounted) {
          scaffoldMessenger.hideCurrentMaterialBanner();
        }
      });
    }
  }

  // ... (Tus métodos privados _getBackgroundColor, _getTextColor, _getIcon quedan igual) ...

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

