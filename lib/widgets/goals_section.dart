import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/widgets/goal_card.dart';

// ignore: must_be_immutable
class GoalsSection extends StatelessWidget {
  final List<Goal> goals;
  final VoidCallback onAddTap;
  final Function(String) onDelete;
  final Function(Goal) onAddMoney;
  final VoidCallback onVisibleTap;
  final bool isVisible;
  final String? focusGoalId;
  final String? heroTag;
  final ScrollController? scrollController; // <--- NUEVO

  const GoalsSection({
    super.key,
    required this.goals,
    required this.onAddTap,
    required this.onDelete,
    required this.onAddMoney,
    required this.isVisible,
    required this.onVisibleTap,
    this.focusGoalId,
    this.heroTag,
    this.scrollController, // <--- NUEVO
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
                      ),
                      onPressed: onAddTap, // <--- Abre el modal de metas
                    ),

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
                    reverse: true,
                    controller:
                        scrollController, // <--- ASIGNAR EL CONTROLLER AQUÍ
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      // Opcional: Resaltar sutilmente la tarjeta enfocada
                      final isFocused = goal.id == focusGoalId;
                      // 4. Guardamos la tarjeta en una variable
                      Widget cardChild = GoalCard(goal: goal);

                      // 5. Si coincide con el ID y hay un tag, la envolvemos en el Hero
                      if (isFocused && heroTag != null) {
                        cardChild = Hero(
                          tag: heroTag!,
                          // Agregamos un flightShuttleBuilder para controlar el renderizado en el aire
                          flightShuttleBuilder:
                              (
                                flightContext,
                                animation,
                                flightDirection,
                                fromHeroContext,
                                toHeroContext,
                              ) {
                                return Material(
                                  color: Colors.transparent,
                                  child: toHeroContext.widget,
                                );
                              },
                          // Añadir un Material interno mantiene los estilos de texto intactos durante el viaje
                          child: Material(
                            color: Colors.transparent,
                            child: cardChild,
                          ),
                        );
                      }

                      return GestureDetector(
                        onLongPress: () => onDelete(goal.id),
                        onTap: () => onAddMoney(goal),
                        child: isVisible
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: isFocused
                                      ? Border.all(
                                          color: Colors.purpleAccent,
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: cardChild,
                              )
                            : const SizedBox.shrink(),
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
