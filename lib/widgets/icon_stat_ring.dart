import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class IconStatRing extends StatelessWidget {
  final double spentPercentage; // De 0.0 a 1.0
  final double totalBalance;
  final IconData iconData;
  final Color iconColor;

  const IconStatRing({
    super.key,
    required this.spentPercentage,
    required this.totalBalance,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color progressColor = totalBalance < 0 || spentPercentage > 0.8
        ? AppThemeHSL.expense
        : AppThemeHSL.primary;

    final Color trackColor = totalBalance == 0
        ? Colors.white10
        : totalBalance > 0
        ? AppThemeHSL.income
        : AppThemeHSL.expense.withValues(alpha: .3);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Hacemos que el grosor y el ícono sean relativos al tamaño disponible
        final double strokeWidth = constraints.maxWidth * 0.09;
        final double iconSize = constraints.maxWidth * 0.8;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Efecto "Glow" detrás del indicador
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Anillo de progreso animado
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: spentPercentage),
                duration: const Duration(
                  milliseconds: 1500,
                ), // 1.5s es más fluido
                curve: Curves.easeOutCirc,
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: strokeWidth,
                    backgroundColor: trackColor,
                    color: progressColor,
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
            ),
            // Ícono con un fondo sutil
            Container(
              padding: EdgeInsets.all(constraints.maxWidth * 0.1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.15),
              ),
              child: Icon(iconData, size: iconSize, color: iconColor),
            ),
          ],
        );
      },
    );
  }
}
