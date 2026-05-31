import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';

enum InsightType { positive, warning, info, goal, neutral }

class FinanceInsight {
  FinanceInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isExpanded = false,
    this.actionText,
    this.icon,
  });

  final String id;
  final String title;
  final String description;
  final InsightType type;
  final bool isExpanded; // Ahora es final
  final String? actionText;
  final String? icon;

  // Método copyWith para crear copias modificadas del objeto (Ideal para el estado)
  FinanceInsight copyWith({
    String? id,
    String? title,
    String? description,
    InsightType? type,
    bool? isExpanded,
    String? actionText,
    String? icon,
  }) {
    return FinanceInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isExpanded: isExpanded ?? this.isExpanded,
      actionText: actionText ?? this.actionText,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceInsight &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

List<FinanceInsight> _getDynamicInsights(
  Map<DateTime, List<dynamic>> eventMap,
) {
  List<FinanceInsight> insights = [];
  final today = DateUtils.dateOnly(DateTime.now());

  // 1. Facturas pendientes - Una notificación por cada factura
  final todayEvents = eventMap[today] ?? [];
  final pendingBills = todayEvents
      .whereType<Bill>()
      .where((b) => !b.isPaid)
      .toList();

  for (var bill in pendingBills) {
    insights.add(
      FinanceInsight(
        id: 'bill_${bill.id}_${today.toIso8601String()}', // ID único
        title: 'Factura pendiente',
        description: '${bill.title} - Vence hoy',
        type: InsightType.warning,
        icon: '📅',
        actionText: 'Pagar ahora',
      ),
    );
  }

  // 2. Metas próximas - Una notificación por meta
  final nextWeek = List.generate(7, (i) => today.add(Duration(days: i)));
  final Set<String> processedGoalIds = {}; // Evitar duplicados

  for (var date in nextWeek) {
    final goals = (eventMap[date] ?? []).whereType<Goal>().toList();

    for (var goal in goals) {
      // Evitar duplicar la misma meta si aparece en múltiples días
      if (!processedGoalIds.contains(goal.id)) {
        processedGoalIds.add(goal.id);

        final daysUntilTarget = date.difference(today).inDays;
        String description;

        if (daysUntilTarget == 0) {
          description = '${goal.title} - ¡Fecha objetivo hoy!';
        } else if (daysUntilTarget == 1) {
          description = '${goal.title} - Fecha objetivo mañana';
        } else {
          description = '${goal.title} - En $daysUntilTarget días';
        }

        insights.add(
          FinanceInsight(
            id: 'goal_${goal.id}_${date.toIso8601String()}',
            title: 'Meta próxima',
            description: description,
            type: InsightType.positive,
            icon: '🏆',
            actionText: 'Ver meta',
          ),
        );
      }
    }
  }

  // 3. Transacciones del día - Una notificación por transacción
  final todayTxs = todayEvents.whereType<Transaction>().toList();

  for (var tx in todayTxs) {
    final amountSign = tx.type == TransactionType.income ? '+' : '-';
    final category = tx.categoryDisplay;

    insights.add(
      FinanceInsight(
        id: 'tx_${tx.id}_${today.toIso8601String()}',
        title:
            '${tx.type == TransactionType.income ? 'Ingreso' : 'Gasto'} registrado',
        description: '$category - $amountSign\$${tx.amount.toStringAsFixed(2)}',
        type: InsightType.info,
        icon: tx.type == TransactionType.income ? '📈' : '📉',
        actionText: 'Ver detalle',
      ),
    );
  }

  // Opcional: Agregar un resumen diario si hay muchas transacciones
  if (todayTxs.length > 3) {
    final totalIncome = todayTxs
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final totalExpense = todayTxs
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    insights.insert(
      0, // Insertar al principio como resumen
      FinanceInsight(
        id: 'summary_$today',
        title: 'Resumen del día',
        description:
            '${todayTxs.length} transacciones | Ingresos: \$${totalIncome.toStringAsFixed(2)} | Gastos: \$${totalExpense.toStringAsFixed(2)}',
        type: InsightType.info,
        icon: '📊',
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
  // Usamos el ID del insight en lugar del título para evitar que se abran varios a la vez
  final Map<String, bool> _expandedStates = {};

  // Llevamos un registro de los IDs que el usuario ha descartado ("borrado")
  final Set<String> _dismissedInsightIds = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
        // 1. Generamos los insights en tiempo real
        List<FinanceInsight> dynamicData = _getDynamicInsights(eventMap);

        // 2. FILTRAMOS los que el usuario ya ha descartado
        dynamicData = dynamicData
            .where((insight) => !_dismissedInsightIds.contains(insight.id))
            .toList();

        if (dynamicData.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "No hay novedades financieras hoy. ¡Todo bajo control!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        return ExpansionPanelList(
          elevation: 0,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              final insightId = dynamicData[index].id;
              // Es más seguro alternar el estado que tenemos guardado
              _expandedStates[insightId] =
                  !(_expandedStates[insightId] ?? false);
            });
          },
          children: dynamicData.map<ExpansionPanel>((FinanceInsight insight) {
            final Color typeColor = _getInsightColor(insight.type);
            // Buscamos el estado usando el ID
            final bool isExpanded = _expandedStates[insight.id] ?? false;

            return ExpansionPanel(
              backgroundColor: const Color(0xFF1E1E1E),
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
                              // Lógica de navegación
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
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              // Agregamos el ID a la lista de descartados
                              _dismissedInsightIds.add(insight.id);

                              // Si este era el último elemento visible, hacemos el pop
                              if (dynamicData.length == 1) {
                                Navigator.pop(context);
                              }
                            });
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
