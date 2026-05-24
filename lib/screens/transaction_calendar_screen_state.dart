import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/finxup_files/mock-trans-expanders/expansion_finance_insight_panel_.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_goal_form.dart';
import 'package:the_finxup_app/widgets/bill_card.dart';
import 'package:the_finxup_app/widgets/calendar_goal_card.dart';
import 'package:the_finxup_app/widgets/slidable_item.dart';
import 'package:the_finxup_app/widgets/transactions_card.dart';
import 'package:table_calendar/table_calendar.dart';
// Importa tu modelo Transaction y TransactionCard

class TransactionCalendarScreen extends ConsumerStatefulWidget {
  const TransactionCalendarScreen({super.key});

  @override
  ConsumerState<TransactionCalendarScreen> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<TransactionCalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado combinado
    final calendarAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Transacciones', style: TextStyle(fontSize: 16)),
        actions: [
          // Botón de alternar visibilidad (con estilo de cápsula)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextButton.icon(
              onPressed: () => setState(() => isVisible = !isVisible),
              label: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 28,
              ),
              style: TextButton.styleFrom(
                foregroundColor:
                    AppThemeHSL.textPrimary, // O el color de tu tema
                backgroundColor: AppThemeHSL.textPrimary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // Pequeño margen al final
        ],
      ),
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (eventMap) {
          // Esta función ahora es ultra rápida porque el mapa ya existe
          // ignore: no_leading_underscores_for_local_identifiers
          List<dynamic> _getEventsForDay(DateTime day) {
            return eventMap[DateUtils.dateOnly(day)] ?? [];
          }

          return SafeArea(
            child: Column(
              children: [
                if (isVisible)
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListTile(),
                                Text('Total de eventos: ${eventMap.length}'),
                                Text('Total de eventos: ${eventMap.length}'),
                                Text('Total de eventos: ${eventMap.length}'),
                                Text('Total de eventos: ${eventMap.length}'),
                                Text('Total de eventos: ${eventMap.length}'),
                                Text('Total de eventos: ${eventMap.length}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                TableCalendar(
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
                  },
                  // --- ESTILOS PERSONALIZADOS ---
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: AppThemeHSL.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: AppThemeHSL.accentGold,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: AppThemeHSL.accentGold,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    // Estilo del día seleccionado
                    selectedDecoration: BoxDecoration(
                      color: AppThemeHSL.accentGold,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),

                    // Estilo del día actual (hoy)
                    todayDecoration: BoxDecoration(
                      color: AppThemeHSL.accentGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppThemeHSL.accentGold,
                        width: 1,
                      ),
                    ),
                    todayTextStyle: TextStyle(color: AppThemeHSL.accentGold),

                    // Días normales
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.white70),
                    outsideDaysVisible: false,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    weekendStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.map((e) {
                          Color color;
                          if (e is Transaction) {
                            color = AppThemeHSL.income;
                          } else if (e is Bill) {
                            color = AppThemeHSL.accentGold;
                          } else if (e is Goal) {
                            color = Colors.purpleAccent; // Color para metas
                          } else {
                            color = Colors.grey;
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Transacciones Programadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
          fixedSize: const Size(12, 12), // Width: 200, Height: 50
          backgroundColor: AppThemeHSL.textPrimary.withValues(alpha: 0.1), // Sets the background color
          // foregroundColor: AppThemeHSL.textPrimary, // Sets the text/icon color
        ),
        onPressed: () {
          // Obtenemos las coordenadas del toque
          // double x = details.globalPosition.dx;
          // double y = details.globalPosition.dy;

          showMenu(
            context: context,
            // Creamos un pequeño rectángulo en el punto del toque
            position: RelativeRect.fromLTRB(0.0, 400.0, 0.0, 20.0),
            items: [
              // const PopupMenuItem(child: ExpansionPanelListItem()),
              const PopupMenuItem(child: ExpansionFinanceInsightPanel()),
            ],
          );
        },
        onLongPress: () {
          showAboutDialog(context: context, applicationName: 'The Finzup App');
        },
        child: Icon(
          Icons.notification_important,
          size: 28,
          color: AppThemeHSL.textPrimary,
        ),
      ),
    );
  }

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
              // Navigator.pop(context);
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
          ref
              .read(goalListNotifierProvider.notifier)
              .delete(goal.id); // eliminamos la antigua
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    if (events.isEmpty) return const Center(child: Text("Día libre de gastos"));

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        if (event is Transaction) {
          return SlidableItem(
            onDelete: () => _deleteTransaction(event.id),
            child: TransactionsCard(transaction: event),
          );
        }
        if (event is Bill) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BillCard(bill: event, isPaid: event.isPaid),
          );
        }
        if (event is Goal) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: CalendarGoalCard(goal: event),
          );
        }
        return const SizedBox();
      },
    );
  }
}
