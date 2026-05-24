// Un Notifier simple para manejar un String
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

// Un simple proveedor para el texto
final searchProvider = StateProvider<String>((ref) => "");

class RealTimeInputScreen extends ConsumerStatefulWidget {
  const RealTimeInputScreen({super.key});

  @override
  ConsumerState<RealTimeInputScreen> createState() =>
      _RealTimeInputScreenState();
}

class _RealTimeInputScreenState extends ConsumerState<RealTimeInputScreen> {
  // 1. Declaramos el controlador
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 2. Inicializamos
    _controller = TextEditingController();

    // 3. CONEXIÓN EN TIEMPO REAL:
    // Añadimos un listener que se ejecuta con cada cambio de texto
    _controller.addListener(() {
      ref.read(searchProvider.notifier).state = _controller.text;
    });
  }

  @override
  void dispose() {
    // 4. IMPORTANTE: Limpiar el controlador para evitar fugas de memoria
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Escuchamos el provider (esto se redibuja en tiempo real)
    final liveText = ref.watch(searchProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Escribe algo en el campo de abajo y verás el cambio instantáneo gracias a Riverpod!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppThemeHSL.textPrimary.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeHSL.backgroundDeep.withValues(alpha: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  liveText,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Escribe algo...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
