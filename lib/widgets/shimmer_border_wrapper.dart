import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShimmerBorderWrapper extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final bool repeat; // true: bucle infinito | false: una sola vez al iniciar
  final bool isCircular;
  final double borderRadius;
  final double strokeWidth;
  final Color shimmerColor; // Color personalizado para el brillo

  const ShimmerBorderWrapper({
    super.key,
    required this.child,
    this.isAnimating = true,
    this.repeat = true,
    this.isCircular = false,
    this.borderRadius = 16.0,
    this.strokeWidth = 2.0,
    this.shimmerColor = Colors.amberAccent, // Color por defecto
  });

  @override
  State<ShimmerBorderWrapper> createState() => _ShimmerBorderWrapperState();
}

class _ShimmerBorderWrapperState extends State<ShimmerBorderWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _manageAnimation();
  }

  // 🔥 Lógica centralizada para manejar el inicio y repetición
  void _manageAnimation() {
    if (widget.isAnimating) {
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward(from: 0);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(covariant ShimmerBorderWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambian las condiciones de animación, actualizamos el controlador
    if (widget.isAnimating != oldWidget.isAnimating ||
        widget.repeat != oldWidget.repeat) {
      _manageAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: widget.isAnimating
              ? _ShimmerPainter(
                  progress: _controller.value,
                  isCircular: widget.isCircular,
                  borderRadius: widget.borderRadius,
                  strokeWidth: widget.strokeWidth,
                  isAnimating: widget.isAnimating,
                  shimmerColor: widget.shimmerColor, // Pasamos el color
                )
              : null, // No dibuja nada si no está animando
          child: Padding(padding: const EdgeInsets.all(12.0), child: child),
        );
      },
      child: widget.child,
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final bool isCircular;
  final double borderRadius;
  final double strokeWidth;
  final bool isAnimating;
  final Color shimmerColor;

  _ShimmerPainter({
    required this.progress,
    required this.isCircular,
    required this.borderRadius,
    required this.strokeWidth,
    required this.isAnimating,
    required this.shimmerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    paint.shader = SweepGradient(
      colors: [
        Colors.transparent,
        shimmerColor, // Usamos el color dinámico
        Colors.transparent,
      ],
      stops: const [0.0, 0.1, 0.7], // Ajusta la longitud del destello aquí
      transform: GradientRotation(progress * 2 * math.pi), // Ajusta la velocidad del destello aquí / mientras mas alto 2, mas rapido
    ).createShader(Offset.zero & size);

    // 🔥 Dibuja un círculo o un rectángulo redondeado según el parámetro
    if (isCircular) {
      // Ajustamos el radio para que el trazo quede exactamente sobre el borde del indicador
      final radius = (size.width / 2) - (strokeWidth / 2);
      canvas.drawCircle(size.center(Offset.zero), radius, paint);
    } else {
      final rect = RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isCircular != isCircular ||
        oldDelegate.isAnimating != isAnimating;
  }
}
