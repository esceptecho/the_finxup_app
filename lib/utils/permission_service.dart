import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission(BuildContext context) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Si es Android 13 o superior (SDK 33+)
      // Nota: En 2026, la mayoría de dispositivos serán 13+
      status = await Permission.photos.request();
    } else {
      // Para iOS o Android antiguo
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // Si el usuario marcó "No volver a preguntar"
      if (context.mounted) {
        _showSettingsDialog(context);
      }
      return false;
    }

    return false;
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso necesario'),
        content: const Text(
          'Para adjuntar archivos, necesitamos acceso a tu galería. '
          'Por favor, actívalo en los ajustes de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings(); // Función de permission_handler
              Navigator.pop(context);
            },
            child: const Text('Ir a Ajustes'),
          ),
        ],
      ),
    );
  }
}
