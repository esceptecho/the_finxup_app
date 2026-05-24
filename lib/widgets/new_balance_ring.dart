import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class NewBalanceRing extends StatelessWidget {
  final double spentPercentage; // De 0.0 a 1.0
  final double totalBalance;

  const NewBalanceRing({
    super.key,
    required this.spentPercentage,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculamos los colores fuera del árbol para mayor claridad
    final Color progressColor = totalBalance < 0 || spentPercentage > 0.8
        ? AppThemeHSL.expense
        : AppThemeHSL
              .primary; // Si el balance es negativo o el gasto supera el 80%, el progreso es rojo, sino vino.

    final Color trackColor = totalBalance == 0
        ? Colors.white10
        : totalBalance > 0
        ? AppThemeHSL.accentGold
        : AppThemeHSL
              .expense; // Si el balance es cero, el track es dorado, sino un gris claro.

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: spentPercentage),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 14, // Un poco más delgado suele verse más moderno
                backgroundColor: trackColor,
                color: progressColor,
                strokeCap:
                    StrokeCap.round, // Bordes redondeados para un look moderno
                
              );
            },
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
              style: TextStyle(
                color: AppThemeHSL.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              softWrap: true,
              overflow: .fade,
            ),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  "${(spentPercentage * 100).toInt()}% gastado",
                  textStyle: TextStyle(
                    color: AppThemeHSL.textSecondary,
                    fontSize: 20,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
