import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class IconStatRing extends StatelessWidget {
  final double percentage; // Ahora acepta -100 a +100 o más
  final double totalBalance;
  final IconData iconData;
  final Color iconColor;

  const IconStatRing({
    super.key,
    required this.percentage,
    required this.totalBalance,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Normalizar el porcentaje para el CircularProgressIndicator (0.0 a 1.0)
    final double absolutePercentage = percentage.abs() / 100.0;
    final double normalizedProgress = absolutePercentage.clamp(0.0, 1.0);

    // Determinar colores basados en el porcentaje real
    final bool isPositive = percentage > 0;
    final bool isNeutral = percentage == 0;

    final Color progressColor = isNeutral
        ? Colors.white10
        : isPositive
        ? AppThemeHSL
              .incomeLight // Balance positivo → verde/ingresos
        : AppThemeHSL.expense; // Balance negativo → rojo/gastos

    final Color trackColor = isNeutral
        ? Colors.white10
        : isPositive
        ? AppThemeHSL.incomeLight.withValues(alpha: 0.2)
        : AppThemeHSL.expense.withValues(alpha: 0.2);

    // Color del icono según el balance
    final Color dynamicIconColor = isNeutral
        ? iconColor
        : isPositive
        ? AppThemeHSL.incomeLight
        : AppThemeHSL.expense;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double strokeWidth = constraints.maxWidth * 0.09;
        final double iconSize = constraints.maxWidth * 0.7;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Efecto "Glow" dinámico según el balance
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withValues(alpha: 0.15),
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
                tween: Tween<double>(begin: 0, end: normalizedProgress),
                duration: const Duration(milliseconds: 1500),
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

            // Ícono dinámico según el balance
            Container(
              padding: EdgeInsets.all(constraints.maxWidth * 0.15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                _getDynamicIcon(),
                size: iconSize,
                color: dynamicIconColor,
              ), 
            ),

            // Indicador de porcentaje en el centro (opcional pero útil)
            // if (percentage != 0)
            //   Positioned.fill(
            //     child: Center(
            //       child: Text(
            //         '${percentage > 0 ? "+" : ""}${percentage.toStringAsFixed(0)}%',
            //         style: TextStyle(
            //           color: progressColor,
            //           fontSize: constraints.maxWidth * 0.25,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        );
      },
    );
  }

  // Método helper para elegir el icono según el balance
  IconData _getDynamicIcon() {
    if (percentage == 0) {
      return iconData; // Usa el icono proporcionado si es neutro
    } else if (percentage > 0) {
      return Icons.trending_up_rounded;
    } else {
      return Icons.trending_down_rounded;
    }
  
  }
}
