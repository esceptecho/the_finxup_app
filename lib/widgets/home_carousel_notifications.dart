import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/providers/notification_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';

class HomeCarouselNotifications extends ConsumerWidget {
const HomeCarouselNotifications({ super.key });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return SizedBox(
      height: 180, // Altura fija para el encabezado
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9), // Para ver un poco de la siguiente tarjeta
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final note = notifications[index];
          return _CarouselCard(notification: note);
        },
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final AppNotification notification;
  const _CarouselCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    // Definimos el gradiente según el tipo de notificación
    final List<Color> gradientColors = _getGradient(notification.type);

    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: .min,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(notification.icon, color: Colors.white.withOpacity(0.5), size: 50),
        ],
      ),
    );
  }

  List<Color> _getGradient(BannerType type) {
    switch (type) {
      case BannerType.success: return [Colors.teal[400]!, Colors.teal[700]!];
      case BannerType.error: return [Colors.red[400]!, Colors.red[700]!];
      case BannerType.warning: return [AppThemeHSL.accentGold, AppThemeHSL.incomeDark,];
      case BannerType.info:
        return [Colors.indigo[400]!, Colors.indigo[700]!];
    }
  }
}