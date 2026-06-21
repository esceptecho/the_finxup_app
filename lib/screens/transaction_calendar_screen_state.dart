import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/widgets/expansion_finance_insight_panel_.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_goal_form.dart';
import 'package:the_finxup_app/widgets/bill_card.dart';
import 'package:the_finxup_app/widgets/calendar_goal_card.dart';
import 'package:the_finxup_app/widgets/debt_card_item.dart';
import 'package:the_finxup_app/widgets/slidable_item.dart';
import 'package:the_finxup_app/widgets/transactions_card.dart';
import 'package:table_calendar/table_calendar.dart';

class TransactionCalendarScreen extends ConsumerStatefulWidget {
  const TransactionCalendarScreen({super.key});

  @override
  ConsumerState<TransactionCalendarScreen> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<TransactionCalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  bool isVisible = false;
  
  // Variables para el overlay
  OverlayEntry? _overlayEntry;
  DateTime? _hoveredDay;
  final GlobalKey _calendarKey = GlobalKey();
  
  // Variable para controlar el modo de exploración
  bool _isPreviewMode = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hoveredDay = null;
  }

  // NUEVO: Mostrar overlay al seleccionar un día (siempre)
  void _showOverlayForSelectedDay(DateTime day, List<dynamic> events) {
    // Solo mostrar si hay eventos y no estamos ya mostrando este día
    if (_hoveredDay == day && _overlayEntry != null) return;
    if (events.isEmpty) {
      _removeOverlay();
      return;
    }
    
    _removeOverlay();
    _hoveredDay = day;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.12,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: Container(
            width: 280,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: AppThemeHSL.surface.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppThemeHSL.accentGold.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppThemeHSL.accentGold.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(
                      bottom: BorderSide(
                        color: AppThemeHSL.accentGold.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: AppThemeHSL.accentGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDayName(day),
                              style: TextStyle(
                                color: AppThemeHSL.accentGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${day.day}/${day.month}/${day.year}',
                              style: TextStyle(
                                color: AppThemeHSL.textPrimary.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppThemeHSL.accentGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${events.length}',
                          style: TextStyle(
                            color: AppThemeHSL.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          _removeOverlay();
                          setState(() {
                            _selectedDay = day;
                            _focusedDay = day;
                            _isPreviewMode = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppThemeHSL.accentGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.push_pin,
                            color: AppThemeHSL.accentGold,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _removeOverlay,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.red.withValues(alpha: 0.8),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de eventos
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: events.length.clamp(0, 5),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventPreview(event, index);
                    },
                  ),
                ),
                if (events.length > 5)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppThemeHSL.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+ ${events.length - 5} eventos más',
                          style: TextStyle(
                            color: AppThemeHSL.accentGold.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  String _getDayName(DateTime date) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[date.weekday - 1];
  }

  Widget _buildEventPreview(dynamic event, int index) {
    Color accentColor;
    String title;
    String subtitle;
    IconData icon;

    if (event is Map<String, dynamic> && event['tipo'] == 'cuota_deuda') {
      accentColor = Colors.orangeAccent;
      title = event['nombre'] ?? 'Cuota';
      subtitle = '\$${event['monto']?.toStringAsFixed(2) ?? '0.00'}';
      icon = Icons.receipt_outlined;
    } else if (event is Transaction) {
      accentColor = event.amount >= 0 ? AppThemeHSL.income : AppThemeHSL.expense;
      title = event.description;
      subtitle = '\$${event.amount.toStringAsFixed(2)}';
      icon = event.amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward;
    } else if (event is Bill) {
      accentColor = AppThemeHSL.accentGold;
      title = event.title;
      subtitle = '\$${event.amount.toStringAsFixed(2)}';
      icon = Icons.receipt;
    } else if (event is Goal) {
      accentColor = Colors.purpleAccent;
      title = event.title;
      subtitle = '\$${event.targetAmount.toStringAsFixed(2)}';
      icon = Icons.flag;
    } else if (event is Debt) {
      accentColor = Colors.redAccent;
      title = event.nombre;
      subtitle = '\$${event.cantidad.toStringAsFixed(2)}';
      icon = Icons.money_off;
    } else {
      accentColor = Colors.grey;
      title = 'Evento';
      subtitle = '';
      icon = Icons.event;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(calendarEventsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Transacciones', style: TextStyle(fontSize: 16)),
        actions: [
          // Toggle para activar/desactivar modo preview
          if (calendarAsync is AsyncData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isPreviewMode = !_isPreviewMode;
                    if (!_isPreviewMode) _removeOverlay();
                  });
                },
                icon: Icon(
                  _isPreviewMode ? Icons.touch_app : Icons.touch_app_outlined,
                  size: 20,
                  color: _isPreviewMode ? AppThemeHSL.accentGold : AppThemeHSL.textPrimary,
                ),
                label: Text(
                  _isPreviewMode ? 'Explorar' : '',
                  style: TextStyle(fontSize: 12, color: AppThemeHSL.accentGold),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: _isPreviewMode 
                      ? AppThemeHSL.accentGold.withValues(alpha: 0.15)
                      : AppThemeHSL.textPrimary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<CalendarFormat>(
              segments: const [
                ButtonSegment<CalendarFormat>(
                  value: CalendarFormat.month,
                  label: Text('Mes'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment<CalendarFormat>(
                  value: CalendarFormat.week,
                  label: Text('Semana'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment<CalendarFormat>(
                  value: CalendarFormat.twoWeeks,
                  label: Text('2 Sem.'),
                  icon: Icon(Icons.view_agenda),
                ),
              ],
              selected: {calendarFormat},
              onSelectionChanged: (Set<CalendarFormat> newSelection) {
                setState(() {
                  calendarFormat = newSelection.first;
                  _removeOverlay();
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppThemeHSL.accentGold;
                  }
                  return AppThemeHSL.textPrimary.withValues(alpha: 0.1);
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.black;
                  }
                  return AppThemeHSL.textPrimary;
                }),
              ),
            ),
          ),
        ),
      ),
      body: calendarAsync.when(
        loading: () =>  Center(
          child: CircularProgressIndicator(color: AppThemeHSL.accentGold),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(calendarEventsFutureProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (eventMap) {
          List<dynamic> _getEventsForDay(DateTime day) {
            return eventMap[DateUtils.dateOnly(day)] ?? [];
          }

          return SafeArea(
            child: Column(
              children: [
                if (isVisible)
                  SizedBox(
                    height: 120,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        color: AppThemeHSL.surface,
                        child: const Center(child: Text('Panel', style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                TableCalendar(
                  key: _calendarKey,
                  calendarFormat: calendarFormat,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Mes',
                    CalendarFormat.week: 'Semana',
                    CalendarFormat.twoWeeks: '2 Semanas',
                  },
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2030),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    
                    // Siempre mostrar overlay del día seleccionado
                    if (!_isPreviewMode) {
                      final events = _getEventsForDay(selectedDay);
                      _showOverlayForSelectedDay(selectedDay, events);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _removeOverlay(); // Limpiar overlay al cambiar de mes
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: AppThemeHSL.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: AppThemeHSL.accentGold),
                    rightChevronIcon: Icon(Icons.chevron_right, color: AppThemeHSL.accentGold),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: AppThemeHSL.accentGold,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppThemeHSL.accentGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppThemeHSL.accentGold, width: 1),
                    ),
                    todayTextStyle: TextStyle(color: AppThemeHSL.accentGold),
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.white70),
                    outsideDaysVisible: false,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    weekendStyle: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.take(3).map((e) {
                          Color color;
                          if (e is Transaction) {
                            color = AppThemeHSL.income;
                          } else if (e is Bill) {
                            color = AppThemeHSL.accentGold;
                          } else if (e is Goal) {
                            color = Colors.purpleAccent;
                          } else if (e is Debt) {
                            color = Colors.redAccent;
                          } else if (e is Map<String, dynamic> && e['tipo'] == 'cuota_deuda') {
                            color = Colors.orangeAccent;
                          } else {
                            color = Colors.grey;
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    // NUEVO: Builder para modo exploración
                    defaultBuilder: _isPreviewMode ? (context, date, _) {
                      return GestureDetector(
                        onTap: () {
                          // Al hacer tap en modo exploración, mostrar overlay
                          final events = _getEventsForDay(date);
                          _showOverlayForSelectedDay(date, events);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSameDay(_selectedDay, date) 
                                ? AppThemeHSL.accentGold 
                                : Colors.transparent,
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSameDay(date, DateTime.now())
                                  ? AppThemeHSL.accentGold
                                  : Colors.white,
                              fontWeight: isSameDay(_selectedDay, date)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    } : null,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Transacciones Programadas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildEventList(_getEventsForDay(_selectedDay)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          fixedSize: const Size(12, 12),
          backgroundColor: AppThemeHSL.textPrimary.withValues(alpha: 0.1),
        ),
        onPressed: () {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(0.0, 400.0, 0.0, 20.0),
            items: [
              const PopupMenuItem(child: ExpansionFinanceInsightPanel()),
            ],
          );
        },
        child: Icon(Icons.notification_important, size: 28, color: AppThemeHSL.textPrimary),
      ),
    );
  }

  // ... resto de métodos (_buildEventList, _deleteTransaction, etc.) ...


  void _deleteTransaction(String id) {
    ref.read(transactionListNotifierProvider.notifier).deleteTransaction(id);
  }


  void _confirmDeleteGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeHSL.surface,
        title: const Text(
          "¿Qué deseas hacer?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text("Meta: ${goal.title}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              _openEditGoalModal(goal);
            },
            child: Text(
              "Editar",
              style: TextStyle(color: AppThemeHSL.accentGoldBright),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalListNotifierProvider.notifier).delete(goal.id);
              Navigator.pop(context);
            },
            child: Text(
              "Eliminar",
              style: TextStyle(color: AppThemeHSL.expense),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditGoalModal(Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGoalForm(
        initialGoal: goal,
        onAdd: (updatedGoal) {
          ref.read(goalListNotifierProvider.notifier).add(updatedGoal);
          ref.read(goalListNotifierProvider.notifier).delete(goal.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 48,
              color: AppThemeHSL.textPrimary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "Día libre de gastos",
              style: TextStyle(
                color: AppThemeHSL.textPrimary.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        if (event is Map<String, dynamic> && event['tipo'] == 'cuota_deuda') {
          final originalDebt = event['deudaOriginal'] as Debt;
          final double monto = event['monto'] as double;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            child: Card(
              color: AppThemeHSL.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.orangeAccent.withValues(alpha: 0.2),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.receipt_outlined,
                    color: Colors.orangeAccent,
                  ),
                ),
                title: Text(
                  event['nombre'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  "Deuda: ${originalDebt.nombre} • Estado: ${event['estado']}",
                  style: TextStyle(
                    color: AppThemeHSL.textPrimary.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  '\$${monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }

        if (event is Transaction) {
          return SlidableItem(
            onDelete: () => _deleteTransaction(event.id),
            child: TransactionsCard(transaction: event),
          );
        }

        if (event is Bill) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: BillCard(bill: event, isPaid: event.isPaid),
          );
        }

        if (event is Goal) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: CalendarGoalCard(goal: event),
          );
        }

        if (event is Debt) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: DebtCardItem(
              debt: event,
              onCheckChanged: () {
                ref.read(debtListProvider.notifier).togglePagado(event.id);
              },
              onDelete: () {
                ref.read(debtListProvider.notifier).deleteDebt(event.id);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
