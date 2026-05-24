import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/widgets/goal_card.dart';

// ignore: must_be_immutable
class GoalsSection extends StatelessWidget {
  final List<Goal> goals;
  final VoidCallback onAddTap; // <--- Nuevo callback
  final Function(String) onDelete;
  final Function(Goal) onAddMoney;
  final VoidCallback onVisibleTap;
  bool isVisible = true;

  GoalsSection({
    super.key,
    required this.goals,
    required this.onAddTap,
    required this.onDelete,
    required this.onAddMoney,
    required this.isVisible,
    required this.onVisibleTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goals.isNotEmpty ? "Mis Metas" : "Agregar Metas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: .end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        size: 32,
                        // color: AppTheme.primaryWine,
                      ),
                      onPressed: onAddTap, // <--- Abre el modal de metas
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     isVisible
                    //         ? Icons.visibility_off_outlined
                    //         : Icons.visibility_outlined,
                    //     size: 28,
                    //   ),
                    //   onPressed: onVisibleTap, // <--- Abre el modal de metas
                    // ),
                  ],
                ),
                
              ],
            ),
          ),
          // ... resto del L-iew.builder
          goals.isNotEmpty
              ? SizedBox(
                  height: 160, // Altura del carrusel
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return GestureDetector(
                        onLongPress: () => onDelete(
                          goal.id,
                        ), // <-- Aquí enviamos el ID al padre
                        onTap: () => onAddMoney(goal),
                        child: isVisible ? GoalCard(goal: goal) : SizedBox.shrink(),
                      );
                    },
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
