import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: .scaleDown,
      child: Container(
        width: 340, // Ancho fijo para scroll horizontal
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeHSL.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                Text(
                  goal.progressText,
                  style: TextStyle(
                    color: AppThemeHSL.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              goal.title,
              style: TextStyle(
                color: AppThemeHSL.textPrimary,
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Barra de progreso personalizada
            Stack(
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: goal.progress,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppThemeHSL.accentGold,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeHSL.accentGold.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: AppThemeHSL.divider,),
            Column(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .start,
              children: [
                Text(
                  "\$${goal.currentAmount.toInt()}/\$${goal.targetAmount.toInt()}", // or toDouble()
                  style: const TextStyle(color: Colors.white54, fontSize: 20),
                ),
                Text(
                  "Fecha Objetivo: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}", // or toDouble()
                  style: const TextStyle(color: Colors.white54, fontSize: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
