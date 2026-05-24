import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class WelcomeSummaryCard extends StatelessWidget {
  final String userName;
  final String statusMessage;
  final int pendingAlerts;
  final VoidCallback? onActionTap;
  final VoidCallback? onTap;

  const WelcomeSummaryCard({
    super.key,
    required this.userName,
    required this.statusMessage,
    this.pendingAlerts = 0,
    this.onActionTap,
    this.onTap,
  });

  // Función sencilla para determinar el saludo según la hora del día
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppThemeHSL.primaryExtraLight, AppThemeHSL.surfaceMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección Superior: Avatar y Saludo
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.update_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                // Si tienes foto de perfil usa: backgroundImage: NetworkImage('url'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()},',
                      style: TextStyle(
                        color: Colors.blue[100],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (onActionTap != null)
              InkWell(
                    onTap: onActionTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
            ],
          ),

          const SizedBox(height: 20),

          // Sección Inferior: Resumen de Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  pendingAlerts > 0
                      ? Icons.notifications_active
                      : Icons.check_circle_outline,
                  color: pendingAlerts > 0
                      ? Colors.orange[300]
                      : Colors.green[300],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                if (onActionTap != null)
                  InkWell(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.blue[900],
                      ),
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
