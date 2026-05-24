// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/models/welcome_update_videos.dart';
import 'package:the_finxup_app/providers/list_notifier.dart';
import 'package:the_finxup_app/providers/new_financial_summary_provider.dart';
import 'package:the_finxup_app/providers/notification_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/screens/dashboard_finantial_health.dart';
import 'package:the_finxup_app/screens/goal_prediction_screen.dart';
import 'package:the_finxup_app/screens/new_tolerance_calculator_screen.dart';
import 'package:the_finxup_app/screens/statistics_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_goal_form.dart';
import 'package:the_finxup_app/widgets/balance_legend.dart';
import 'package:the_finxup_app/widgets/bill_card.dart';
import 'package:the_finxup_app/widgets/category_filter_selector.dart';
import 'package:the_finxup_app/widgets/colorize_names_widget.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';
import 'package:the_finxup_app/widgets/goals_section.dart';
import 'package:the_finxup_app/widgets/health_status_widget.dart';
import 'package:the_finxup_app/widgets/icon_stat_ring.dart';
import 'package:the_finxup_app/widgets/movimientos.dart';
import 'package:the_finxup_app/widgets/shimmer_border_wrapper.dart';
import 'package:the_finxup_app/widgets/slidable_item.dart';
import 'package:the_finxup_app/widgets/summary_card.dart';
import 'package:the_finxup_app/widgets/transaction_card.dart';
import 'package:the_finxup_app/widgets/video_welcome_card.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen> {
  bool _isShowingTransactions = true;
  bool isVisible = true;
  bool isSumaryVisible = true;
  bool _isGoalsVisible = true;
  bool _welcomeSummaryCardShown = false;
  bool _welcomeVdeoCardShown = false;
  static const int _hoursThreshold = 6; //Ajustar horas a voluntad
  static const int _hoursVideoThreshold = 3; //Ajustar horas a voluntad

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
    _checkWelcomeVideoStatus();
  }

  Future<void> _checkWelcomeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener la última fecha en que se mostró
    String? lastShownStr = prefs.getString('welcome_last_shown');
    bool shouldShow = false;

    if (lastShownStr == null) {
      // Primera vez que se abre la app
      shouldShow = true;
    } else {
      // Verificar si han pasado las horas necesarias
      DateTime lastShown = DateTime.parse(lastShownStr);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastShown);

      if (difference.inHours >= _hoursThreshold) {
        shouldShow = true;
      }
    }

    // SIF: Verificamos si el widget sigue vivo antes de hacer setState
    if (!mounted) return;

    setState(() {
      _welcomeSummaryCardShown = shouldShow;
    });

    // Si se determinó que debe mostrarse, actualizamos la fecha en el almacenamiento
    if (shouldShow) {
      await prefs.setString(
        'welcome_last_shown',
        DateTime.now().toIso8601String(),
      );
    }
  }

  Future<void> _checkWelcomeVideoStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener la última fecha en que se mostró
    String? lastShownStr = prefs.getString('welcome_video_last_shown');
    bool shouldShow = false;

    if (lastShownStr == null) {
      // Primera vez que se abre la app
      shouldShow = true;
    } else {
      // Verificar si han pasado las horas necesarias
      DateTime lastShown = DateTime.parse(lastShownStr);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastShown);

      if (difference.inHours >= _hoursVideoThreshold) {
        shouldShow = true;
      }
    }

    // SIF: Verificamos si el widget sigue vivo antes de hacer setState
    if (!mounted) return;

    setState(() {
      _welcomeVdeoCardShown = shouldShow;
    });

    // Si se determinó que debe mostrarse, actualizamos la fecha en el almacenamiento
    if (shouldShow) {
      await prefs.setString(
        'welcome_video_last_shown',
        DateTime.now().toIso8601String(),
      );
    }
  }

  void _openAddGoalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddGoalForm(
        // Usamos 'ctx' para el formulario
        onAdd: (newGoal) async {
          // 1. Obtenemos el navigator antes de que el contexto sea inválido
          final navigator = Navigator.of(ctx);

          // 2. Cerramos el modal
          navigator.pop();

          // 3. Ejecutamos la lógica de Riverpod usando el 'ref' del Widget padre
          await ref.read(goalListNotifierProvider.notifier).add(newGoal);
        },
      ),
    );
  }

  void _showAddMoneyDialog(Goal goal) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeHSL.surface,
        title: Text(
          "Abonar a ${goal.title}",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Monto a ahorrar"),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(amountController.text);
              if (monto != null) {
                final updatedGoal = goal.copyWith(
                  currentAmount: goal.currentAmount + monto,
                );
                ref.read(goalListNotifierProvider.notifier).add(updatedGoal);
                Navigator.pop(context);
              }
            },
            child: const Text("Abonar"),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    // Escuchas atómicas (Performance óptimo)
    final transactionsAsync = ref.watch(transactionListNotifierProvider);
    final summary = ref.watch(financialSummaryProvider);
    final goalsList = ref.watch(goalListNotifierProvider).value ?? [];
    final billsList = ref.watch(billListNotifierProvider).value ?? [];
    final transactionList = ref.watch(filteredTransactionsProvider);
    // final isExpanded = ref.watch(listProvider.select((s) => s.isExpanded));

    return transactionsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) =>
          Scaffold(body: Center(child: Text("Error al cargar datos: $err"))),
      data: (transactions) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: CustomScrollView(
            slivers: [
              // 1. Header con Balances Optimizados
              SliverToBoxAdapter(
                child: HomeHeaderBackground(
                  balance: summary.balance,
                  income: summary.income,
                  expense: summary.expense,
                  spentPercentage: summary.percentage,
                  transactions: transactions,
                ),
              ),

              // 2. Bloques Condicionales de Bienvenida
              if (_welcomeVdeoCardShown) _buildVideoWelcomeCard(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              const SliverToBoxAdapter(child: FinancialHealthCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // 3. Sección de Metas
              SliverToBoxAdapter(
                child: goalsList.isNotEmpty
                    ? GoalsSection(
                        goals: goalsList,
                        onAddTap: _openAddGoalModal,
                        onVisibleTap: () =>
                            setState(() => _isGoalsVisible = !_isGoalsVisible),
                        isVisible: _isGoalsVisible,
                        onDelete: (id) => _confirmDeleteGoal(
                          goalsList.firstWhere((g) => g.id == id),
                        ),
                        onAddMoney: _showAddMoneyDialog,
                      )
                    : _buildEmptyGoalsPlaceholder(),
              ),

              if (_welcomeSummaryCardShown) ...[
                // mover aqui para condicionar
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildSummaryCard(),

              // if (isSumaryVisible)
              // if (_welcomeSummaryCardShown)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // if (isSumaryVisible)
              // if (_welcomeSummaryCardShown)
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  padding: EdgeInsets.only(top: 16),
                  color: AppThemeHSL.surfaceLight,
                  child: Stack(
                    alignment: .centerLeft,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Salud Financiera",
                            style: TextStyle(
                              color: AppThemeHSL.textPrimary,
                              fontSize: 18,
                            ),
                          ),
                          DashboardFinancialHealth(),
                        ],
                      ),
                      Positioned(
                        bottom: 15,
                        right: 20,
                        child: TextButton(
                          autofocus: true,
                          //iconSize: 20,
                          child: Text(
                            'Cerrar',
                            style: TextStyle(color: AppThemeHSL.textSecondary),
                          ),
                          onPressed: () {
                            setState(() {
                              isSumaryVisible = !isSumaryVisible;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Filtros y Listados dinámicos
              if (transactionList.isNotEmpty || billsList.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                const SliverToBoxAdapter(
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      child: Text(
                        'Movimientos Recientes',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: CategoryFilterSelector(
                    showTransactions: _isShowingTransactions,
                    onChanged: (val) =>
                        setState(() => _isShowingTransactions = val),
                  ),
                ),

                // const SliverToBoxAdapter(child: SizedBox(height: 8)),
                _buildSliverList(
                  isShowingTransactions: _isShowingTransactions,
                  transactions: transactionList,
                  bills: billsList,
                ),
              ],

              // 5. Botón expandible de transacciones
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  // --- SUBWIDGETS Y MÉTODOS EXTRACTOS PARA LEGIBILIDAD ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final appNotifications = ref.watch(notificationsProvider);
    int notifCount = appNotifications.length - 1;

    return AppBar(
      backgroundColor: AppThemeHSL.background,
      title: ColorizeNamesWidget(
        names: const ['Arees', 'Tu Finanzas', 'Tu Futuro', ' F i n x U p'],
        colors: [
          AppThemeHSL.textPrimary,
          AppThemeHSL.primary,
          AppThemeHSL.accentGold,
          AppThemeHSL.income,
        ],
        fontSize: 16,
      ),
      centerTitle: true,
      leading: _buildAppBarLeading(context),
      actions: _buildAppBarActions(appNotifications, notifCount),
    );
  }

  // --- MÉTODOS DE LA APP BAR ---
  Widget _buildAppBarLeading(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewToleranceCalculatorScreen(),
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/arees_profile.jpeg'),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(
    List<dynamic> appNotifications,
    int notifCount,
  ) {
    return [
      IconButton(
        icon: Badge.count(
          count: notifCount,
          maxCount: 99,
          textStyle: const TextStyle(fontSize: 10.0),
          backgroundColor: notifCount > 0
              ? AppThemeHSL.primaryLight
              : AppThemeHSL.textDisabled,
          child: Icon(Icons.notifications, color: AppThemeHSL.textSecondary),
        ),
        onPressed: () {
          if (appNotifications.isNotEmpty) {
            ElegantBanner.show(
              ref: ref,
              // SIF: Convertimos la lista dinámica a una lista de AppNotification en tiempo de ejecución
              appNotifications: appNotifications.cast<AppNotification>(),
              context,
              customBackgroundColor: AppThemeHSL.surfaceLight,
              customTextColor: Colors.purple[200],
              autoDismiss: false,
              duration: const Duration(seconds: 4),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No hay nuevas notificaciones")),
            );
          }
        },
      ),
      IconButton(
        icon: Badge(
          textStyle: const TextStyle(fontSize: 10.0),
          backgroundColor: notifCount > 0
              ? AppThemeHSL.primaryLight
              : AppThemeHSL.textDisabled,
          child: Icon(Icons.list, color: AppThemeHSL.textSecondary, size: 32),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GoalPredictionsScreen(),
            ),
          );
        },
      ),
    ];
  }

  // --- COMPONENTES CONDICIONALES DE BIENVENIDA ---
  Widget _buildVideoWelcomeCard() {
    String video = getRandomWelcomeVideo();
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppThemeHSL.background,
          borderRadius: BorderRadius.circular(7),
        ),
        child: VideoWelcomeCard(
          userName: 'Arees',
          videoPath: video, //'assets/videos/BienvenidosEscepTechOS0.mp4',
          videoType: VideoSourceType.asset,
          onActionTap: () => setState(() => _welcomeVdeoCardShown = false),
          onTap: () {
            setState(() {
              _welcomeVdeoCardShown = false;
              Navigator.pushNamed(context, '/home');
            });
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppThemeHSL.background,
          borderRadius: BorderRadius.circular(7),
        ),
        child: SummaryCard(
          userName: 'Arees',
          onCloseTap: () => setState(() => _welcomeSummaryCardShown = false),
          onDetailsTap: () => Navigator.pushNamed(context, '/analytics'),
        ),
      ),
    );
  }

  Widget _buildEmptyGoalsPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeHSL.surfaceLighter,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: _openAddGoalModal,
            icon: const Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Colors.white54,
            ),
          ),
          const Text(
            "Agrega tu primera meta para ahorrar",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverList({
    required bool isShowingTransactions,
    required List<Transaction> transactions,
    required List<Bill> bills,
  }) {
    final items = isShowingTransactions ? transactions : bills;

    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 120.0),
            child: Text(
              isShowingTransactions
                  ? "No hay movimientos"
                  : "No hay facturas pendientes",
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (isShowingTransactions) {
            final tx = transactions[index];
            return SlidableItem(
              onDelete: () async {
                // Esperar a que termine la animación del slide
                await Future.delayed(const Duration(milliseconds: 300));
                _deleteTransaction(tx.id);
              },
              child: TransactionCard(transaction: tx),
            );
          } else {
            final bill = bills[index];
            return SlidableItem(
              onDelete: () => _deleteBill(bill.id),
              onToggleStatus: () => _markBillAsPaid(bill),
              child: BillCard(bill: bill, isPaid: false),
            );
          }
        },
        childCount: isShowingTransactions ? transactions.length : bills.length,
      ),
    );
  }

  // --- MÉTODOS DE ACCIÓN ---
  void _markBillAsPaid(Bill bill) async {
    // 1. Crear el objeto de transacción
    final tx = Transaction(
      description: "Pago: ${bill.title}",
      amount: bill.amount,
      type: TransactionType.expense,
      date: DateTime.now(),
      iconCodePoint: Icons.check_circle.codePoint,
    );

    // 2. Llamar a los notifiers
    // Primero agregamos la transacción
    await ref.read(transactionListNotifierProvider.notifier).addTransaction(tx);

    // Luego borramos la factura
    await ref.read(billListNotifierProvider.notifier).delete(bill.id);

    // Al usar Notifiers con invalidateSelf(), la UI se actualizará sola
  }

  void _deleteTransaction(String id) {
    ref.read(transactionListNotifierProvider.notifier).deleteTransaction(id);
  }

  void _deleteBill(String id) {
    ref.read(billListNotifierProvider.notifier).delete(id);
  }
}

class AddMoneyDialog extends StatefulWidget {
  final Goal goal;
  final ValueChanged<double> onAmountSubmitted;

  const AddMoneyDialog({
    super.key,
    required this.goal,
    required this.onAmountSubmitted,
  });

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    // SIF: Liberamos el controlador de la memoria obligatoriamente
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeHSL.surface,
      title: Text(
        "Abonar a ${widget.goal.title}",
        style: const TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: "Monto a ahorrar"),
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final monto = double.tryParse(_amountController.text);
            if (monto != null && monto > 0) {
              widget.onAmountSubmitted(monto);
              Navigator.pop(context);
            }
          },
          child: const Text("Abonar"),
        ),
      ],
    );
  }
}

class HomeHeaderBackground extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final double spentPercentage;
  final List<Transaction> transactions;

  const HomeHeaderBackground({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.spentPercentage,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            AppThemeHSL.divider,
            BlendMode.hardLight,
          ),
          image: const AssetImage('assets/fondo_degradado_login.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(7),
          bottomRight: Radius.circular(7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemeHSL.accentGoldSoft.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Columna Izquierda: Balances Financieros
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Balance Total',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppThemeHSL.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          CurrencyFormatter.formatAmount(
                            balance,
                          ), // Uso del Formateador óptimo
                          style: TextStyle(
                            color: balance > 0
                                ? AppThemeHSL.incomeLight
                                : AppThemeHSL.expenseLight,
                            // AppThemeHSL.textPrimary.withValues( alpha: .8),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ShimmerBorderWrapper(
                      strokeWidth: 0.5,
                      isAnimating: true,
                      repeat: false,
                      shimmerColor: Colors.transparent,
                      // balance > 0
                      //     ? AppThemeHSL.incomeLight
                      //     : AppThemeHSL.expenseLight,
                      child: Movimientos(),
                    ),
                  ],
                ),
              ),

              // Columna Derecha: Anillo Interactivo (Stats)
              Expanded(
                child: Hero(
                  tag: 'IconStatRing',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(7),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Hero(
                              tag: 'IconStatRing',
                              child: StatisticsScreen(
                                transactions: transactions,
                              ),
                            ),
                          ),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ShimmerBorderWrapper(
                          strokeWidth: 0.2,
                          isAnimating: true,
                          repeat: false,
                          shimmerColor: Colors.transparent,
                          // balance > 0
                          //     ? AppThemeHSL.incomeLight
                          //     : AppThemeHSL.expenseLight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const BalanceLegend(),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: IconStatRing(
                                  totalBalance: balance,
                                  percentage: spentPercentage,
                                  iconData: Icons.bar_chart,
                                  iconColor: AppThemeHSL.textSecondary,
                                ),
                              ),
                              TextButton.icon(
                                label: Text(
                                  'Ver Stats',
                                  style: TextStyle(
                                    color: AppThemeHSL.textSecondary,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.ads_click,
                                  color: AppThemeHSL.textSecondary,
                                  size: 22,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialRow(IconData icon, Color color, double amount) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 4),
            Text(
              CurrencyFormatter.formatAmount(amount),
              style: TextStyle(color: color, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}
