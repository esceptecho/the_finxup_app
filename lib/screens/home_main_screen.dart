// ignore_for_file: avoid_print

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/list_notifier.dart';
import 'package:the_finxup_app/providers/notification_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/screens/dashboard_finantial_health.dart';
import 'package:the_finxup_app/screens/goal_prediction_screen.dart';
import 'package:the_finxup_app/screens/new_tolerance_calculator_screen.dart';
import 'package:the_finxup_app/screens/statistics_screen.dart';
import 'package:the_finxup_app/screens/user_profile_header.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_goal_form.dart';
import 'package:the_finxup_app/widgets/add_transaction_form.dart';
import 'package:the_finxup_app/widgets/balance_legend.dart';
import 'package:the_finxup_app/widgets/bill_card.dart';
import 'package:the_finxup_app/widgets/category_filter_selector.dart';
import 'package:the_finxup_app/widgets/colorize_names_widget.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';
import 'package:the_finxup_app/widgets/goals_section.dart';
import 'package:the_finxup_app/widgets/icon_stat_ring.dart';
import 'package:the_finxup_app/widgets/shimmer_border_wrapper.dart';
import 'package:the_finxup_app/widgets/slidable_item.dart';
import 'package:the_finxup_app/widgets/summary_card.dart';
import 'package:the_finxup_app/widgets/transaction_card.dart';
import 'package:the_finxup_app/widgets/video_welcome_card.dart';
import 'package:the_finxup_app/widgets/welcome_summary_card.dart';

class HomeMainScreen extends ConsumerStatefulWidget {
  const HomeMainScreen({super.key});

  @override
  ConsumerState<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends ConsumerState<HomeMainScreen> {
  bool _isShowingTransactions = true;
  bool isVisible = true;
  bool isSumaryVisible = true;
  bool _welcomeSummaryCardShown = false;
  // Cambia esto según las horas que necesites
  static const int _hoursThreshold = 2;

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
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
    final appNotifications = ref.watch(notificationsProvider);
    int notifCount = appNotifications.length - 1;
    // Obtenemos solo la lista ya procesada (ordenada y limitada)
    final transactionList = ref.watch(filteredTransactionsProvider);
    // Necesitamos el estado para saber si el botón dice "Ver más" o "Ver menos"
    final isExpanded = ref.watch(listProvider.select((s) => s.isExpanded));

    final transactionsAsync = ref.watch(transactionListNotifierProvider);
    final billsAsync = ref.watch(billListNotifierProvider);
    final goalsAsync = ref.watch(goalListNotifierProvider);

    // LOG DE DEPURACIÓN
    transactionsAsync.whenData((list) {
      print(
        '🖥️ UI: Dibujando HomeMainScreen con ${list.length} transacciones',
      );
    });

    // Usamos un Scaffold de carga/error global o manejamos los estados dentro del CustomScrollView
    return transactionsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) {
        print("❌ ERROR CRÍTICO EN PROVIDER: $err");
        return Scaffold(
          body: Center(child: Text("Error al cargar datos: $err")),
        );
      },
      data: (transactions) {
        // Formateador con idioma español
        // final dateFormat = DateFormat('d \'de\' MMMM', 'es');
        // Aquí extraemos el resto de la data que ya sabemos que está cargada
        final goals = goalsAsync.value ?? [];
        final bills = billsAsync.value ?? [];
        // final bill = bills.isNotEmpty
        // ? bills.first
        // : null; // Solo para el mensaje de bienvenida

        // 3. Cálculos de Balance
        final double totalIncome = transactions
            .where((tx) => tx.type == TransactionType.income)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        final double totalExpense = transactions
            .where((tx) => tx.type == TransactionType.expense)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        final double calculatedBalance = totalIncome - totalExpense;
        final double spentPercentage = totalIncome == 0
            ? 0.0
            : (totalExpense / totalIncome).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            title: ColorizeNamesWidget(
              names: ['Arees', 'Tu Finanzas', 'Tu Futuro', ' F i n x U p'],
              colors: [
                AppThemeHSL.textPrimary,
                AppThemeHSL.primary,
                AppThemeHSL.accentGold,
                AppThemeHSL.income,
              ],
              fontSize: 16,
            ),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => NewToleranceCalculatorScreen(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/arees_profile.jpeg'),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Badge.count(
                  count: notifCount,
                  maxCount: 99,
                  textStyle: TextStyle(fontSize: 10.0),
                  backgroundColor: notifCount > 0
                      ? AppThemeHSL.primaryLight
                      : AppThemeHSL.textDisabled,
                  child: Icon(
                    Icons.notifications,
                    color: AppThemeHSL.textSecondary,
                  ),
                ),
                onPressed: () {
                  appNotifications.isNotEmpty
                      ? ElegantBanner.show(
                          ref: ref,
                          appNotifications: appNotifications,
                          context,
                          customBackgroundColor: AppThemeHSL.surfaceLight,
                          customTextColor: Colors.purple[200],
                          autoDismiss: false,

                          duration: const Duration(seconds: 4),
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No hay nuevas notificaciones"),
                          ),
                        );
                  print('🖥️ UI: Contando notifCount: $notifCount');
                },
              ),
              IconButton(
                icon: Badge(
                  textStyle: TextStyle(fontSize: 10.0),
                  backgroundColor: notifCount > 0
                      ? AppThemeHSL.primaryLight
                      : AppThemeHSL.textDisabled,
                  child: Icon(
                    Icons.list,
                    color: AppThemeHSL.textSecondary,
                    size: 32,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalPredictionsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          body: CustomScrollView(
            slivers: [
              // 1. Header con Balance
              SliverToBoxAdapter(
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // color: AppThemeHSL.primary,
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                        AppThemeHSL.divider,
                        BlendMode.modulate,
                      ),
                      image: const AssetImage(
                        'assets/fondo_degradado_login.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.25, // Un poco más transparente para contraste
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(
                        35,
                      ), // Bordes un poco más pronunciados
                    ),
                    // Sombra inferior para separar la tarjeta del resto de la app
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeHSL.accentGoldSoft.withValues(
                          alpha: 0.05,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25.0,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Columna Izquierda: Textos
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Balance Total',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppThemeHSL.textSecondary,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    scrollDirection: .horizontal,
                                    child: Text(
                                      '\$${calculatedBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                      style: TextStyle(
                                        color: AppThemeHSL.textPrimary
                                            .withValues(alpha: .8),
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                      softWrap: true,
                                      overflow: .fade,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Ingresos y Gastos
                                SizedBox(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    scrollDirection: .horizontal,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_upward_rounded,
                                          color: AppThemeHSL.incomeLight,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '\$${totalIncome.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                          style: TextStyle(
                                            color: AppThemeHSL.incomeLight,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    scrollDirection: .horizontal,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_downward_rounded,
                                          color: AppThemeHSL.expense,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '\$${totalExpense.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                          style: TextStyle(
                                            color: AppThemeHSL.expenseLight,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Texto Animado
                                AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      "${(spentPercentage * 100).toInt()}% gastado del límite",
                                      textStyle: TextStyle(
                                        color: AppThemeHSL.textSecondary
                                            .withValues(alpha: 0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      speed: const Duration(milliseconds: 100),
                                    ),
                                  ],
                                  isRepeatingAnimation: false,
                                ),
                              ],
                            ),
                          ),

                          // Columna Derecha: Botón/Anillo interactivo
                          Expanded(
                            child: Hero(
                              tag: 'IconStatRing',
                              child: Column(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        40,
                                      ), // Forma del ripple
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
                                          strokeWidth: 2.0,
                                          isAnimating: true,
                                          repeat: false,
                                          shimmerColor: AppThemeHSL.textPrimary,
                                          child: Column(
                                            mainAxisAlignment: .spaceEvenly,
                                            children: [
                                              const BalanceLegend(),
                                              const SizedBox(height: 24),
                                              SizedBox(
                                                height:
                                                    80, // Tamaño definido para el LayoutBuilder
                                                width: 80,

                                                child: IconStatRing(
                                                  totalBalance:
                                                      calculatedBalance,
                                                  spentPercentage:
                                                      spentPercentage,
                                                  iconData: Icons.bar_chart,
                                                  iconColor:
                                                      AppThemeHSL.textSecondary,
                                                ),
                                              ),
                                              // const SizedBox(height: 8),
                                              TextButton.icon(
                                                label: Text(
                                                  'Ver Stats',
                                                  style: TextStyle(
                                                    color: AppThemeHSL
                                                        .textSecondary,
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.ads_click,
                                                  color:
                                                      AppThemeHSL.textSecondary,
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Separador
              if (_welcomeSummaryCardShown)
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // 3. Tarjeta de Resumen (Condicional)
              _welcomeSummaryCardShown
                  ? SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppThemeHSL.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            VideoWelcomeCard(
                              userName: 'Arees',
                              videoPath: 'assets/BienvenidosEscepTechOS0.mp4',
                              // videoPath: 'https://canva.link/fz67a2dmvmjs0f0', // PRESENTACION CANAL
                              // videoPath: 'https://canva.link/cs7d7c0bejzixcu', // PHISHING

                              // videoPath: 'https://canva.link/1r64waa98bfviat', // PRESENTACION ESCEPTECHOS
                              videoType: VideoSourceType.asset,
                              onActionTap: () {
                                setState(() {
                                  _welcomeSummaryCardShown = false;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  _welcomeSummaryCardShown = false;
                                  Navigator.pushNamed(context, '/home');
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              if (_welcomeSummaryCardShown)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppThemeHSL.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        SummaryCard(
                          userName: 'Arees',
                          onCloseTap: () {
                            setState(() {
                              _welcomeSummaryCardShown = false;
                            });
                          },
                          onDetailsTap: () {
                            // Por ejemplo, navegar a la sección de analíticas detalladas
                            Navigator.pushNamed(context, '/analytics');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Sección de Metas
              SliverToBoxAdapter(
                child: goals.isNotEmpty
                    ? GoalsSection(
                        goals: goals,
                        onAddTap: _openAddGoalModal,
                        onVisibleTap: () =>
                            setState(() => isVisible = !isVisible),
                        isVisible: isVisible,
                        onDelete: (id) => _confirmDeleteGoal(
                          goals.firstWhere((g) => g.id == id),
                        ),
                        onAddMoney: _showAddMoneyDialog,
                      )
                    : _buildEmptyGoalsPlaceholder(),
              ),
              // if (isSumaryVisible)
              if (_welcomeSummaryCardShown)
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // if (isSumaryVisible)
              if (_welcomeSummaryCardShown)
                SliverToBoxAdapter(
                  child: Container(
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
                                fontSize: 22,
                              ),
                            ),
                            DashboardFinancialHealth(),
                          ],
                        ),
                        Positioned(
                          bottom: 15,
                          right: 20,
                          child: TextButton(
                            //iconSize: 20,
                            child: Text(
                              'Cerrar',
                              style: TextStyle(
                                color: AppThemeHSL.textSecondary,
                              ),
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
              if (isVisible)
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // DESPUÉS (En tu CustomScrollView)
              SliverToBoxAdapter(
                // Cambiamos a ToBoxAdapter porque el contenido ahora crece solo
                child: CategoryFilterSelector(
                  showTransactions: _isShowingTransactions,
                  onChanged: (val) =>
                      setState(() => _isShowingTransactions = val),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 8)),
              _buildSliverList(
                isShowingTransactions: _isShowingTransactions,
                transactions:
                    transactionList, // transactions = data: (transactions) {...}
                bills: bills,
              ),
              if (_isShowingTransactions &&
                  transactions.length > 2) // solo controlamos las transacciones
                SliverToBoxAdapter(
                  child: TextButton.icon(
                    onPressed: () =>
                        ref.read(listProvider.notifier).toggleExpansion(),
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppThemeHSL.textDisabled,
                    ),
                    label: Text(
                      isExpanded
                          ? "Mostrar menos"
                          : "Ver últimas transacciones",
                      style: TextStyle(
                        color: AppThemeHSL.textDisabled,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: UserProfileHeader()),
              SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddCardModal(context);
            },
            backgroundColor: AppThemeHSL.primaryExtraLight,
            elevation: 4,
            heroTag:
                spentPercentage, // Evita conflictos de hero animation si hay más de un FAB en la app
            enableFeedback: true, // Feedback táctil para mejor UX
            child: Icon(Icons.add, color: AppThemeHSL.textPrimary),
          ),
          floatingActionButtonLocation: .miniEndFloat,
        );
      },
    );
  }

  void _showAddCardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionForm(
        isBillMode: !_isShowingTransactions,
        onAdd: (newTx) async => await ref
            .read(transactionListNotifierProvider.notifier)
            .addTransaction(newTx),
        onAddBill: (newBill) =>
            ref.read(billListNotifierProvider.notifier).add(newBill),
      ),
    );
  }

  Widget _buildEmptyGoalsPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeHSL.surfaceLighter,
        borderRadius: BorderRadius.circular(20),
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
