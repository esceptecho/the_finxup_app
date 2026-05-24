import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/notification_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/utils/app_banners.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:the_finxup_app/widgets/home_carousel_notifications.dart';

class AnimatedNotificationsDashboard extends ConsumerWidget {
  const AnimatedNotificationsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppThemeHSL.background,
      appBar: AppBar(
        actions: [
          IconButton.outlined(
            onPressed: () {},
            icon: const Icon(Icons.account_circle),
          ),
        ],
        title: Text(
          'Asistente FinX',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppThemeHSL.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: AppThemeHSL.background,
        foregroundColor: AppThemeHSL.accentGoldSoft,
      ),
      // Movemos el condicional aquí para que el Empty State se centre correctamente en toda la pantalla
      body: 
      notifications.isEmpty
          ? _buildEmptyState()
          : 
          SingleChildScrollView(
              child: Column(
                children: [
                  // 1. ELIMINADO EL EXPANDED:
                  // El carrusel debe tener su propia altura definida internamente.
                  const HomeCarouselNotifications(),

                  // 2. ANIMATION LIMITER SIN SIZEDBOX FIJO:
                  // Si quieres que todo el contenido haga scroll junto,
                  // no limites la altura a 550.
                  AnimationLimiter(
                    child: MasonryGridView.count(
                      // 3. CONFIGURACIÓN PARA COLUMNA:
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // El scroll lo maneja el SingleChildScrollView
                      padding: const EdgeInsets.all(16),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final note = notifications[index];

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 450),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: NotificationCard(
                                title: note.title,
                                message: note.message,
                                type: note.type,
                                displayHeight: 160,
                                icon: note.icon,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    // Aseguramos que ocupe todo el espacio para que Center funcione
    return const SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Todo está en orden por aquí',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // BannerType _parseType(String t) {
  //   if (t == 'success') return BannerType.success;
  //   if (t == 'warning') return BannerType.warning;
  //   if (t == 'error') return BannerType.error;
  //   return BannerType.info;
  // }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final BannerType type;
  final double displayHeight;
  final IconData icon;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.displayHeight,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos colores basados en la lógica que definimos en ElegantBanner
    final colorScheme = _getCardColors(type);

    return InkWell(
      onTap: () {
        // Ejemplo: Mostrar el banner que hicimos antes al tocar la tarjeta
        AppBanners.show(context, title: title, message: message, type: type);
      },
      onLongPress: () {
        // Acción para vista ampliada o menú contextual
        _showDetailsDialog(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: displayHeight,
        decoration: BoxDecoration(
          color: colorScheme['bg'],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme['text']!.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_getIcon(type), color: colorScheme['text'], size: 20),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme['text'],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: colorScheme['text']!.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers de estilo ---

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getCardColors(BannerType type) {
    switch (type) {
      case BannerType.success:
        return {'bg': Colors.teal[50]!, 'text': Colors.teal[900]!};
      case BannerType.error:
        return {'bg': Colors.red[50]!, 'text': Colors.red[900]!};
      case BannerType.warning:
        return {'bg': Colors.orange[50]!, 'text': Colors.orange[900]!};
      default:
        return {'bg': Colors.blueGrey[50]!, 'text': Colors.blueGrey[900]!};
    }
  }

  IconData _getIcon(BannerType type) {
    switch (type) {
      case BannerType.success:
        return Icons.check_circle_rounded;
      case BannerType.error:
        return Icons.error_rounded;
      case BannerType.warning:
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
