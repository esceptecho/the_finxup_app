import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:the_finxup_app/providers/goal_prediction_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class GoalPredictionsScreen extends ConsumerWidget {
  const GoalPredictionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictions = ref.watch(goalPredictionProvider);

    return Scaffold(
      backgroundColor: AppThemeHSL.surfaceMid, // Color de fondo profundo de tu app
      appBar: AppBar(
        title: const Text(
          'Proyector de Metas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: predictions.isEmpty
            ? _buildEmptyState()
            : _buildPredictionsList(predictions),
      ),
    );
  }

  // --- UI STATE: Cuando no hay metas registradas ---
  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty_state'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.track_changes_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin proyecciones activas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea objetivos de ahorro en tu perfil para que nuestra IA calcule tus plazos estimados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI STATE: Lista de Predicciones Optimizada ---
  Widget _buildPredictionsList(List<dynamic> predictions) {
    return ListView.builder(
      key: const ValueKey('list_state'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: predictions.length + 1, // +1 para agregar el Header superior
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeaderSummary(predictions.length);
        }

        // Ajustamos el índice debido al header
        final pred = predictions[index - 1];
        
        // Determinamos colores dinámicos según el tiempo requerido (UX Semántica)
        final bool isShortTerm = pred.monthsNeeded <= 6;
        final bool isMediumTerm = pred.monthsNeeded > 6 && pred.monthsNeeded <= 18;
        
        final Color statusColor = isShortTerm 
            ? Colors.greenAccent 
            : (isMediumTerm ? Colors.tealAccent : Colors.orangeAccent);

        return Slidable(
          key: UniqueKey(),
          // The start action pane is the one at the left or the top side.
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () {}),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                onPressed: doNothing,
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
              SlidableAction(
                onPressed: doNothing,
                backgroundColor: const Color(0xFF21B7CA),
                foregroundColor: Colors.white,
                icon: Icons.share,
                label: 'Share',
              ),
            ],
          ),

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
                onPressed: doNothing,
                backgroundColor: Color(0xFF7BC043),
                foregroundColor: Colors.white,
                icon: Icons.archive,
                label: 'Archive',
              ),
              SlidableAction(
                onPressed: doNothing,
                backgroundColor: Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.save,
                label: 'Save',
              ),
            ],
          ),

          // The child of the Slidable is what the user sees when the
          // component is not dragged.
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05), // Efecto cristal esmerilado
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                // Línea decorativa lateral izquierda basada en la urgencia del tiempo
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: statusColor, width: 5)),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icono estilizado dentro de un contenedor circular
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.savings_rounded, color: statusColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    
                    // Textos principales
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pred.goalName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pred.message,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Badge derecho del tiempo estimado (KPI resaltado)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${pred.monthsNeeded}',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                        Text(
                          pred.monthsNeeded == 1 ? 'mes' : 'meses',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HEADER DE SOPORTE: Resumen Estadístico ---
  Widget _buildHeaderSummary(int totalGoals) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Proyección',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tienes $totalGoals objetivos calculados',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void doNothing(BuildContext context) {
    print('dismissing');
  }
}
