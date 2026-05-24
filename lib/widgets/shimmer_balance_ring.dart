import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/shimmer_border_wrapper.dart';

class ShimmerBalanceRing extends StatelessWidget {
  final double spentPercentage;
  final double totalBalance;

  const ShimmerBalanceRing({
    super.key,
    required this.spentPercentage,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final Color progressColor = totalBalance < 0 || spentPercentage > 0.8
        ? AppThemeHSL.expenseDark
        : AppThemeHSL.primary;

    final Color trackColor = totalBalance == 0
        ? Colors.white10
        : totalBalance > 0
        ? AppThemeHSL.accentGold
        : AppThemeHSL.expenseDark;

    // final bool shouldAnimateShimmer = totalBalance == 0;
    // Color shimmerColor = AppTheme.textGrey;

    // --- Lógica Reactiva ---

    // 1. ¿Debe animarse? (En este caso, si el balance es 0 o negativo)
    final bool shouldAnimate = totalBalance <= 0;

    // 2. 🔥 Condición para activar la animación
    // ¿Debe repetirse? (Solo en bucle si es exactamente 0, para llamar la atención)
    // final bool shouldRepeat = totalBalance == 0;
    final bool shouldRepeat = false;

    // 3. Color dinámico del brillo
    Color shimmerColor;
    if (totalBalance == 0) {
      shimmerColor = AppThemeHSL.textHint;
    } else if (totalBalance < 0) {
      shimmerColor = AppThemeHSL.expenseDark;
    } else {
      shimmerColor = AppThemeHSL.incomeDark;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          // 🔥 Aquí implementamos el Wrapper reutilizable
          child: ShimmerBorderWrapper(
            isAnimating: shouldAnimate,
            isCircular: true,
            repeat: shouldRepeat, // Bucle infinito
            shimmerColor: shimmerColor, // AppTheme.accentGold,
            strokeWidth: 14, // Mismo grosor que tu CircularProgressIndicator
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: spentPercentage),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 14,
                  backgroundColor: trackColor,
                  color: progressColor,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Balance',
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${totalBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: const TextStyle(
                color: Colors.white, // Asumiendo AppTheme.textWhite
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow
                  .fade, // 🔥 Corregí un pequeño error tipográfico aquí (.fade a TextOverflow.fade)
            ),
            Text(
              "${(spentPercentage * 100).toInt()}% gastado",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ), // Asumiendo AppTheme.textGrey
            ),
          ],
        ),
      ],
    );
  }
}
