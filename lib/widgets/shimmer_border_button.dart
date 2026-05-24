import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/shimmer_border_wrapper.dart';

class ShimmerBorderButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const ShimmerBorderButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ShimmerBorderWrapper(
        isAnimating: true,
        repeat: false, // Se mantiene animando siempre
        shimmerColor: AppThemeHSL.accentGold,
        strokeWidth: 1,
        borderRadius: 16, // Debe coincidir con el BorderRadius del Container
        isCircular: false, // Es un botón rectangular con bordes redondeados
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withValues(alpha: 0.4),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}