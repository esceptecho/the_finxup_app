import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

enum InsightType { positive, warning, info, goal, neutral }

class FinanceInsight {
  FinanceInsight({
    required this.title,
    required this.description,
    required this.type,
    this.isExpanded = false,
    this.actionText, // Ejemplo: "Ver presupuesto"
    this.icon,
  });

  String title;
  String description;
  InsightType type;
  bool isExpanded;
  String? actionText;
  String? icon;
}

List<FinanceInsight> _getDynamicInsights(
  Map<DateTime, List<dynamic>> eventMap,
) {
  List<FinanceInsight> insights = [];
  final today = DateUtils.dateOnly(DateTime.now());

  // 1. Buscar Bills (Facturas) pendientes para hoy o mañana
  final todayEvents = eventMap[today] ?? [];
  final pendingBills = todayEvents
      .whereType<Bill>()
      .where((b) => !b.isPaid)
      .toList();

  if (pendingBills.isNotEmpty) {
    insights.add(
      FinanceInsight(
        title: 'Pagos para hoy',
        description:
            'Tienes ${pendingBills.length} facturas pendientes: ${pendingBills.map((e) => e.title).join(", ")}.',
        type: InsightType.warning,
        icon: '📅',
        actionText: 'Pagar ahora',
      ),
    );
  }

  // 2. Buscar Metas (Goals) cercanas
  // (Buscamos en los próximos 7 días)
  final nextWeek = List.generate(7, (i) => today.add(Duration(days: i)));
  int upcomingGoals = 0;
  for (var date in nextWeek) {
    upcomingGoals += (eventMap[date] ?? []).whereType<Goal>().length;
  }

  if (upcomingGoals > 0) {
    insights.add(
      FinanceInsight(
        title: 'Metas a la vista',
        description:
            '¡Felicidades! Tienes $upcomingGoals metas que alcanzan su fecha objetivo esta semana.',
        type: InsightType.positive,
        icon: '🏆',
        actionText: 'Ver mis metas',
      ),
    );
  }

  // 3. Resumen de gastos del día (Transactions)
  final todayTxs = todayEvents.whereType<Transaction>().toList();
  if (todayTxs.isNotEmpty) {
    final total = todayTxs.fold(0.0, (sum, item) => sum + item.amount);
    insights.add(
      FinanceInsight(
        title: 'Actividad de hoy',
        description:
            'Has registrado ${todayTxs.length} transacciones por un total de \$${total.toStringAsFixed(2)}.',
        type: InsightType.info, // Asumiendo que tienes este tipo
        icon: '💰',
      ),
    );
  }

  return insights; 
}

class ExpansionFinanceInsightPanel extends ConsumerStatefulWidget {
  const ExpansionFinanceInsightPanel({super.key});

  @override
  ConsumerState<ExpansionFinanceInsightPanel> createState() =>
      _ExpansionFinanceInsightPanelState();
}

class _ExpansionFinanceInsightPanelState
    extends ConsumerState<ExpansionFinanceInsightPanel> {
  // 1. ELIMINAMOS: final List<FinanceInsight> _data = generateInsights;
  // Ya no es necesaria porque dynamicData se genera en el build.

  // Mantenemos esto para recordar qué paneles abrió el usuario
  // En tu State, define esto para controlar la expans
  final Map<String, bool> _expandedStates = {};

  @override
  // Widget build(BuildContext context) {
  //   // Es mejor dejar que el build maneje el estado de carga del provider
  //   return _buildPanel();
  // }
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    final calendarAsync = ref.watch(calendarEventsProvider);

    return calendarAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Text(
          "Error al cargar insights: $err",
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (eventMap) {
        // Generamos los insights en tiempo real
        final List<FinanceInsight> dynamicData = _getDynamicInsights(eventMap);

        if (dynamicData.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "No hay novedades financieras hoy. ¡Todo bajo control!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        return ExpansionPanelList(
          elevation:
              0, // Bajamos la elevación para que se vea más moderno (flat)
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              // Usamos el título como llave única para persistir la expansión
              _expandedStates[dynamicData[index].title] = isExpanded;
            });
          },
          children: dynamicData.map<ExpansionPanel>((FinanceInsight insight) {
            final Color typeColor = _getInsightColor(insight.type);
            final bool isExpanded = _expandedStates[insight.title] ?? false;

            return ExpansionPanel(
              backgroundColor: const Color(
                0xFF1E1E1E,
              ), // Ajusta al color de tu AppTheme
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  leading: Text(
                    insight.icon ?? '💡',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    insight.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isExpanded
                          ? typeColor
                          : Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (insight.actionText != null)
                          TextButton(
                            onPressed: () {
                              // Lógica de navegación según el tipo de insight
                            },
                            child: Text(
                              insight.actionText!,
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white30,
                          ),
                          onPressed: () {
                            // Opcional: Implementar una lista de "ocultados" en el estado
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              isExpanded: isExpanded,
            );
          }).toList(),
        );
      },
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Colors.greenAccent;
      case InsightType.warning:
        return Colors.orangeAccent;
      case InsightType.goal:
        return Colors.blueAccent;
      case InsightType.info:
        return Colors.cyanAccent;
      case InsightType.neutral:
        return Colors.white70;
    }
  }
}
