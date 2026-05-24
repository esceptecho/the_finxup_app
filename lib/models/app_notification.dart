import 'package:flutter/material.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final BannerType type;
  final double height;
  final IconData icon;
  final String? imagePath;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.height = 150.0,
    required this.icon,
    this.imagePath,
  });

  // Agregamos este getter para que NotificationTile pueda obtener el color
  Color get color {
    switch (type) {
      case BannerType.success:
        return Colors
            .teal[900]!; // Usamos el color de texto para que sea legible
      case BannerType.error:
        return Colors.red[900]!;
      case BannerType.warning:
        return Colors.orange[900]!;
      case BannerType.info:
        return Colors.blueGrey[900]!;
    }
  }

  // Opcional: Un getter para el color de fondo sutil
  Color get backgroundColor {
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
}
