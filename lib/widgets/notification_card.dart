import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/providers/dismissed_notifications_notifier.dart';
import 'package:the_finxup_app/screens/new_notif_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class NotificationCard extends StatefulWidget {
  final AppNotification notif;
  final Color txtColor;
  final WidgetRef ref;
  final int totalNotifications;

  const NotificationCard({
    super.key,
    required this.notif,
    required this.txtColor,
    required this.ref,
    required this.totalNotifications,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isMarkedAsRead = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.totalNotifications > 1
          ? MediaQuery.of(context).size.width * 0.85
          : MediaQuery.of(context).size.width - 32,
      child: Material(
        // Si está marcada, podemos hacer la tarjeta un poco más translúcida
        color: _isMarkedAsRead
            ? AppThemeHSL.surfaceLight.withValues(alpha: 0.3)
            : AppThemeHSL.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // AL DAR CLIC A LA TARJETA: Solo navegamos al detalle (no la borramos)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewNotifScreen(notification: widget.notif),
              ),
            );
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ÍCONO O IMAGEN ---
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(shape: BoxShape.circle,),
                      child: widget.notif.imagePath != null
                          ? Image.asset(
                              widget.notif.imagePath!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : CircleAvatar(
                              backgroundColor: widget.txtColor.withValues(
                                alpha: 0.1,
                              ),
                              radius: 24,
                              child: Icon(
                                widget.notif.icon,
                                color: widget.txtColor,
                                size: 24,
                              ),
                            ),
                    ),

                    // --- TEXTO ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 32,
                            ), // Espacio para el botón
                            child: Text(
                              widget.notif.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: widget.txtColor,
                                letterSpacing: 0.3,
                                // Efecto de tachado sutil si ya se marcó
                                decoration: _isMarkedAsRead
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.notif.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.txtColor.withValues(alpha: 0.85),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- BOTÓN DE MARCAR COMO LEÍDO (CHECKBOX / CIRCLE) ---
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  // Cambia dinámicamente el ícono y el color
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isMarkedAsRead
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey<bool>(_isMarkedAsRead),
                      color: _isMarkedAsRead
                          ? Colors.green[600]
                          : widget.txtColor.withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: _isMarkedAsRead
                      ? null
                      : () async {
                          // 1. Cambiamos el estado visual local inmediatamente
                          setState(() {
                            _isMarkedAsRead = true;
                          });

                          // 2. Esperamos 400ms para que el usuario vea el ícono verde
                          await Future.delayed(
                            const Duration(milliseconds: 400),
                          );

                          // 3. Pasado el tiempo, impactamos Riverpod (aquí disminuye la cuenta)
                          widget.ref
                              .read(dismissedNotificationsProvider.notifier)
                              .dismiss(widget.notif.id);

                          // 4. Si era la última notificación en pantalla, cerramos el banner por completo
                          if (widget.totalNotifications <= 1) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentMaterialBanner();
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
