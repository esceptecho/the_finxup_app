import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NewCustomAnimationDialog extends StatefulWidget {
  final String title;
  final String lottiePath;
  final Duration duration; // <--- Nueva propiedad
  final List<Widget>? extraContent;

  const NewCustomAnimationDialog({
    super.key,
    required this.title,
    required this.lottiePath,
    this.duration = const Duration(seconds: 2), // Duración por defecto
    this.extraContent,
  });

  @override
  State<NewCustomAnimationDialog> createState() =>
      _NewCustomAnimationDialogState();
}

class _NewCustomAnimationDialogState extends State<NewCustomAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Agregamos un listener para detectar el final de la animación
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Verificamos que el widget siga en pantalla antes de cerrar
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // IMPORTANTE: Liberar memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: Lottie.asset(
                widget.lottiePath,
                controller: _controller, // <--- Vinculamos el controlador
                onLoaded: (composition) {
                  // Esto asegura que el controlador sepa la duración real si no se la pasas
                  _controller.duration = widget.duration;
                },
              ),
            ),
            if (widget.extraContent != null) ...[
              const SizedBox(height: 15),
              ...widget.extraContent!,
            ],
          ],
        ),
      ),
    );
  }
}

class CustomDialogHelper {
  static Future<void> showAnimated(
  BuildContext context, {
  required String title,
  required String lottiePath,
  Duration? duration = const Duration(seconds: 2), 
}) {
  // Obtenemos el contexto del Navigator de más arriba (el root)
  // para que no muera cuando la pantalla actual haga .pop()
  return showDialog(
    context: Navigator.of(context, rootNavigator: true).context,
    barrierDismissible: false, // <--- Evita que se cierre al tocar afuera
    builder: (BuildContext dialogContext) => NewCustomAnimationDialog(
      title: title,
      lottiePath: lottiePath,
    ),
  );
}
}
