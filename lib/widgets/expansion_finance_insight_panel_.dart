import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
// import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/screens/consumer_transaction_screen.dart';
import 'package:the_finxup_app/screens/enhanced_home_screen.dart';
import 'package:the_finxup_app/screens/transaction_full_screen.dart';

enum InsightType { positive, warning, info, goal, neutral }

class FinanceInsight {
  final String id; // ID compuesto para la UI (ej: 'tx_123_fecha')
  final String? originalId; // ¡NUEVO! ID real de Hive/BD (ej: '123')
  final String title;
  final String description;
  final InsightType type;
  final bool isExpanded;
  final String? actionText;
  final String? icon;

  FinanceInsight({
    required this.id,
    this.originalId, // Lo hacemos opcional por si el resumen diario no lo lleva
    required this.title,
    required this.description,
    required this.type,
    this.isExpanded = false,
    this.actionText,
    this.icon,
  });

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

  // 1. Facturas pendientes
  final todayEvents = eventMap[today] ?? [];
  final pendingBills = todayEvents
      .whereType<Bill>()
      .where((b) => !b.isPaid)
      .toList();

  for (var bill in pendingBills) {
    insights.add(
      FinanceInsight(
        id: 'bill_${bill.id}_${today.toIso8601String()}',
        originalId: bill.id, // <-- Guardamos el ID real de la factura
        title: 'Factura pendiente',
        description: '${bill.title} - Vence hoy',
        type: InsightType.warning,
        icon: '📅',
        actionText: 'Pagar ahora',
      ),
    );
  }

  // 2. Metas próximas
  final nextWeek = List.generate(7, (i) => today.add(Duration(days: i)));
  final Set<String> processedGoalIds = {};

  for (var date in nextWeek) {
    final goals = (eventMap[date] ?? []).whereType<Goal>().toList();
    for (var goal in goals) {
      if (!processedGoalIds.contains(goal.id)) {
        processedGoalIds.add(goal.id);
        final daysUntilTarget = date.difference(today).inDays;
        String description = daysUntilTarget == 0
            ? '${goal.title} - ¡Fecha objetivo hoy!'
            : daysUntilTarget == 1
            ? '${goal.title} - Fecha objetivo mañana'
            : '${goal.title} - En $daysUntilTarget días';

        insights.add(
          FinanceInsight(
            id: 'goal_${goal.id}_${date.toIso8601String()}',
            originalId: goal.id, // <-- Guardamos el ID real de la meta
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

  // 3. Transacciones del día
  final todayTxs = todayEvents.whereType<Transaction>().toList();
  for (var tx in todayTxs) {
    final amountSign = tx.type == TransactionType.income ? '+' : '-';
    insights.add(
      FinanceInsight(
        id: 'tx_${tx.id}_${today.toIso8601String()}',
        originalId: tx.id, // <-- Guardamos el ID real de la transacción
        title:
            '${tx.type == TransactionType.income ? 'Ingreso' : 'Gasto'} registrado',
        description:
            '${tx.categoryDisplay} - $amountSign\$${tx.amount.toStringAsFixed(2)}',
        type: InsightType.info,
        icon: tx.type == TransactionType.income ? '📈' : '📉',
        actionText: 'Ver detalle',
      ),
    );
  }

  if (todayTxs.length > 3) {
    final totalIncome = todayTxs
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = todayTxs
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    insights.insert(
      0,
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
  final Map<String, bool> _expandedStates = {};
  final Set<String> _dismissedInsightIds = {};

  void _handleInsightAction(FinanceInsight insight) {
    if (insight.originalId == null) return;

    final String idReal = insight.originalId!;
    final String tagAnimacion = 'hero_${insight.id}'; // Ej: 'hero_goal_123'

    if (insight.id.startsWith('tx_')) {
      _navigateToTransactionDetail(idReal);
    } else if (insight.id.startsWith('bill_')) {
      _navigateToBillManagement(idReal, tagAnimacion);
    } else if (insight.id.startsWith('goal_')) {
      // CORREGIDO: Ahora pasamos también el tagAnimacion
      _navigateToGoalDetail(idReal, tagAnimacion);
    }
  }

  void _navigateToTransactionDetail(String transactionId) {
    // CASO: Detalle de la Transacción
    // Opción con Navigator tradicional (ejemplo si tu pantalla recibe el ID):
    
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TransactionDetailScreen(transactionId: transactionId),
    ),
  );
  

    // Opción si usas GoRouter:
    // context.push('/transactions/$transactionId');

    print('Navegando al detalle de la transacción con ID: $transactionId');
  }

  // CORREGIDO: Ahora la firma acepta la tupla (String, String)
  void _navigateToBillManagement(String billId, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsumerTransactionsScreen(
          focusBillId: billId,
          heroTag:
              heroTag, // Recuerda agregar este campo al constructor de ConsumerTransactionsScreen
        ),
      ),
    );
  }

  void _navigateToGoalDetail(String goalId, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedHomeScreen(
          focusGoalId: goalId,
          heroTag:
              heroTag, // CORREGIDO: Usamos el tag idéntico que viene del origen
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CORREGIDO: Escuchando al provider correcto que usa la pantalla principal
    final calendarAsync = ref.watch(calendarEventsFutureProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: calendarAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: Colors.amber,
              ), // Ajusta al color de tu app
            ),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Error al cargar insights: $err",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          data: (eventMap) {
            final allInsights = _getDynamicInsights(eventMap);

            // CORREGIDO: El filtrado se realiza inmediatamente antes de evaluar si está vacío
            final dynamicData = allInsights
                .where((insight) => !_dismissedInsightIds.contains(insight.id))
                .toList();

            if (dynamicData.isEmpty) {
              return _buildEmptyState();
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ExpansionPanelList(
                elevation: 1,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    final insightId = dynamicData[index].id;
                    _expandedStates[insightId] =
                        !(_expandedStates[insightId] ?? false);
                  });
                },
                children: dynamicData.map<ExpansionPanel>((
                  FinanceInsight insight,
                ) {
                  final Color typeColor = _getInsightColor(insight.type);
                  final bool isExpanded = _expandedStates[insight.id] ?? false;

                  return ExpansionPanel(
                    backgroundColor: const Color(0xFF1E1E1E),
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Hero(
                        tag:
                            'hero_${insight.id}', // <-- Tag único (ej: hero_tx_123_fecha)
                            flightShuttleBuilder:
                            (
                              flightContext,
                              animation,
                              flightDirection,
                              fromHeroContext,
                              toHeroContext,
                            ) {
                              // Opcional: Esto evita saltos visuales feos de tamaño durante la transición
                              return Material(
                                color: Colors.transparent,
                                child: toHeroContext.widget,
                              );
                            },
                        child: ListTile(
                          leading: Text(
                            insight.icon ?? '💡',
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(
                            insight.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isExpanded
                                  ? typeColor
                                  : Colors.white.withAlpha(230),
                            ),
                          ),
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (insight.actionText != null)
                                TextButton(
                                  onPressed: () {
                                    // Ejecuta la acción correspondiente de manera limpia y sin delays innecesarios
                                    _handleInsightAction(insight);
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
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _dismissedInsightIds.add(insight.id);
                                    // Si era el último, cerramos el modal limpiamente
                                    if (dynamicData.length == 1) {
                                      Navigator.of(context).pop();
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.done_all_rounded,
              size: 40,
              color: Colors.white.withAlpha(60),
            ),
            const SizedBox(height: 12),
            const Text(
              "No hay novedades financieras hoy.\n¡Todo está bajo control!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
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
