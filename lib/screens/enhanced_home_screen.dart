// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_finxup_app/models/app_notification.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/models/welcome_update_videos.dart';
import 'package:the_finxup_app/providers/dismissed_notifications_notifier.dart';
import 'package:the_finxup_app/providers/financial_summary_provider.dart';
import 'package:the_finxup_app/providers/goal_prediction_provider.dart';
import 'package:the_finxup_app/providers/notification_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/screens/currency_converter_screen.dart';
import 'package:the_finxup_app/screens/dashboard_finantial_health.dart';
import 'package:the_finxup_app/screens/goal_prediction_screen.dart';
import 'package:the_finxup_app/screens/new_tolerance_calculator_screen.dart';
import 'package:the_finxup_app/screens/notificaton_list_dashboard.dart';
import 'package:the_finxup_app/screens/statistics_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_goal_form.dart';
import 'package:the_finxup_app/widgets/animated_rate_ticker.dart';
import 'package:the_finxup_app/widgets/balance_legend.dart';
import 'package:the_finxup_app/widgets/bill_card.dart';
import 'package:the_finxup_app/widgets/colorize_names_widget.dart';
import 'package:the_finxup_app/widgets/elegant_banner.dart';
import 'package:the_finxup_app/widgets/goals_section.dart';
import 'package:the_finxup_app/widgets/icon_stat_ring.dart';
import 'package:the_finxup_app/widgets/movimientos.dart';
import 'package:the_finxup_app/widgets/shimmer_border_wrapper.dart';
import 'package:the_finxup_app/widgets/slidable_item.dart';
import 'package:the_finxup_app/widgets/summary_card.dart';
import 'package:the_finxup_app/widgets/tarjeta_previsualizacion_deudas.dart';
import 'package:the_finxup_app/widgets/transaction_card.dart';
import 'package:the_finxup_app/widgets/video_welcome_card.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  final String? focusGoalId;
  final String? heroTag;
  const EnhancedHomeScreen({super.key, this.focusGoalId, this.heroTag});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen> {
  // bool _isShowingTransactions = true;
  bool isVisible = true;
  bool isSumaryVisible = true;
  bool _isGoalsVisible = true;
  bool _welcomeVdeoCardShown = false;
  bool _showNotificationBanner = false;
  bool _welcomeSummaryCardShown = false;
  static const int _hoursThreshold = 6; //Ajustar horas a voluntad
  static const int _hoursVideoThreshold = 3; //Ajustar horas a voluntad

  // CONTROLADORES DE SCROLL
  late final ScrollController
  _mainVerticalScrollController; // Para bajar la pantalla
  late final ScrollController _goalsScrollController; // Para mover el carrusel

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
    _checkWelcomeVideoStatus();

    // 1. Calcular offset horizontal del carrusel de metas
    double initialHorizontalOffset = 0.0;
    if (widget.focusGoalId != null) {
      final goals = ref.read(goalListNotifierProvider).value ?? [];
      final index = goals.indexWhere((g) => g.id == widget.focusGoalId);

      if (index != -1) {
        final double cardWidth = 200.0; // Tu ancho real de tarjeta
        initialHorizontalOffset = index * cardWidth;
      }
    }

    // Inicializar controlador horizontal
    _goalsScrollController = ScrollController(
      initialScrollOffset: initialHorizontalOffset,
    );

    // Inicializar controlador vertical principal
    _mainVerticalScrollController = ScrollController();

    // 2. Hacer scroll vertical de la pantalla principal tras el primer renderizado
    if (widget.focusGoalId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToGoalsSection();
      });
    }
  }

  @override
  void dispose() {
    _mainVerticalScrollController.dispose();
    _goalsScrollController.dispose();
    super.dispose();
  }

  /// Método para calcular dinámicamente y deslizar la pantalla principal hacia abajo
  void _scrollToGoalsSection() {
    if (!_mainVerticalScrollController.hasClients) return;

    // Buscamos la posición máxima o un estimado alto para forzar a la pantalla a bajar
    // hasta donde se encuentre la sección de metas.
    final double maxScroll =
        _mainVerticalScrollController.position.maxScrollExtent;

    // Deslizamos suavemente toda la pantalla verticalmente
    _mainVerticalScrollController.animateTo(
      maxScroll *
          1.00, // Ajusta este multiplicador según la altura de tu salud financiera/resumen
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
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

  void _showNotifBanner(List<AppNotification> notifications) {
    ElegantBanner.show(
      context, // El context va de primero según la firma original
      ref: ref,
      appNotifications: notifications,
      customBackgroundColor: AppThemeHSL.surfaceLight,
      customTextColor: Colors.purple[200],
      autoDismiss: false,
      // ¡IMPORTANTE! Si el banner se cierra desde adentro (ej. al marcar la última),
      // devolvemos el booleano a false para que el botón no se desincronice.
      onBannerClose: () {
        setState(() {
          _showNotificationBanner = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 1. Escuchas atómicas del estado
    final transactionsAsync = ref.watch(transactionListNotifierProvider);
    final summary = ref.watch(financialSummaryProvider);

    // Obtenemos los valores directos (si ya existen en caché, se usarán de inmediato)
    final goalsList = ref.watch(goalListNotifierProvider).value ?? [];
    final transactions = transactionsAsync.value ?? [];

    // 2. EVITAR LOADER GENERAL SI HAY CACHÉ:
    // Solo bloqueamos la pantalla completa si está cargando Y no hay absolutamente nada de datos previos.
    if (transactionsAsync.isLoading &&
        transactions.isEmpty &&
        goalsList.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212), // Ajusta al color de tu app
        body: Center(
          child: CircularProgressIndicator(
            color: Colors
                .amber, // Evita saltos visuales usando tu color de énfasis
          ),
        ),
      );
    }

    // Solo mostramos pantalla de error limpia si no hay datos previos que rescatar
    if (transactionsAsync.hasError && transactions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Error al cargar datos: ${transactionsAsync.error}",
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // 3. Renderizado síncrono e inmediato de la interfaz
    return Scaffold(
      body: CustomScrollView(
        controller:
            _mainVerticalScrollController, // <--- CORREGIDO: Asignamos el controlador vertical principal
        slivers: [
          _buildSliverAppBar(
            context,
            balance: summary.balance,
            income: summary.income,
            expense: summary.expense,
            spentPercentage: summary.percentage,
            transactions: transactions, // Se pasa la lista (vacía o con caché)
          ),

          // Bloques Condicionales de Bienvenida
          if (_welcomeVdeoCardShown)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (_welcomeVdeoCardShown) _buildVideoWelcomeCard(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // En tu navegación principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Material(
                color: AppThemeHSL.surfaceLighter,
                clipBehavior:
                    Clip.antiAlias, // Mantenlo para que el InkWell no se salga
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),

                child: Row(
                  children: [
                    SizedBox(width: 12),
                    // COLUMNA IZQUIERDA: Información y Llamado a la Acción (CTA)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            Text('Dolar contra divisas'),
                            SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton.icon(
                                label: Text('EN VIVO'),
                                onPressed: () {
                                  debugPrint('Navegando al conversor...');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CurrencyConverterScreen(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // COLUMNA DERECHA: El Ticker animado e independiente de Riverpod
                    Expanded(flex: 1, child: const PremiumRateTicker()),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TarjetaPrevisualizacionDeudas(),
            ),
          ),
          if (_welcomeSummaryCardShown) ...[
            // Mover aquí tus elementos condicionales si es necesario
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: AppThemeHSL.surfaceLight,
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Salud Financiera",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      DashboardFinancialHealth(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          _buildSummaryCard(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 4. Sección de Metas (El Hero ya no se destruirá al entrar)
          SliverToBoxAdapter(
            child: goalsList.isNotEmpty
                ? GoalsSection(
                    scrollController:
                        _goalsScrollController, // Controlador horizontal
                    focusGoalId: widget.focusGoalId,
                    heroTag: widget.heroTag,
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
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
      ),
    );
  }

  // --- SUBWIDGETS Y MÉTODOS EXTRACTOS PARA LEGIBILIDAD ---
  Widget _buildSliverAppBar(
    BuildContext context, {
    required double balance,
    required double income,
    required double expense,
    required double spentPercentage,
    required List<Transaction> transactions,
  }) {
    final appNotifications = ref.watch(notificationsProvider);
    int notifCount = appNotifications.length;
    final predictions = ref.watch(goalPredictionProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    print('predictions length = ${predictions.length}');

    return SliverAppBar(
      backgroundColor:
          Colors.transparent, // Fondo transparente para ver el header
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
      actions: _buildAppBarActions(
        appNotifications,
        notifCount,
        predictions.length,
      ),

      expandedHeight: 184 + kToolbarHeight + statusBarHeight, // Altura total
      collapsedHeight: kToolbarHeight + statusBarHeight,
      floating: true,
      pinned: false,

      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            SizedBox(
              height: kToolbarHeight + statusBarHeight,
            ), // Espacio para el AppBar
            Expanded(
              child: HomeHeaderBackground(
                balance: balance,
                income: income,
                expense: expense,
                spentPercentage: spentPercentage,
                transactions: transactions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PreferredSizeWidget _buildAppBar(BuildContext context) {
  //   final appNotifications = ref.watch(notificationsProvider);
  //   int notifCount = appNotifications.length;

  //   return AppBar(
  //     backgroundColor: AppThemeHSL.background,
  //     title: ColorizeNamesWidget(
  //       names: const ['Arees', 'Tu Finanzas', 'Tu Futuro', ' F i n x U p'],
  //       colors: [
  //         AppThemeHSL.textPrimary,
  //         AppThemeHSL.primary,
  //         AppThemeHSL.accentGold,
  //         AppThemeHSL.income,
  //       ],
  //       fontSize: 16,
  //     ),
  //     centerTitle: true,
  //     leading: _buildAppBarLeading(context),
  //     actions: _buildAppBarActions(appNotifications, notifCount),
  //   );
  // }

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
    int predictions,
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotifListScreen()),
          );
        },
        onLongPress: () {
          // Asumiendo que 'appNotifications' ya viene de un ref.watch(notificationsProvider) en tu build
          if (appNotifications.isNotEmpty) {
            setState(() {
              // 1. Invertimos el booleano: si era false pasa a true, si era true pasa a false
              _showNotificationBanner = !_showNotificationBanner;
            });

            // 2. Evaluamos el NUEVO estado para mostrar u ocultar
            if (_showNotificationBanner) {
              _showNotifBanner(appNotifications.cast<AppNotification>());
            } else {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            }
          } else {
            // Si no hay notificaciones, reseteamos el estado por seguridad y avisamos
            setState(() {
              _showNotificationBanner = false;
            });
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No hay nuevas notificaciones")),
            );
          }
        },
      ),
      IconButton(
        icon: Badge(
          textStyle: const TextStyle(fontSize: 10.0),
          backgroundColor:
              predictions >
                  2 // Logica para > 0 fallando
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
        child: ShimmerBorderWrapper(
          strokeWidth: 2.0,
          isAnimating: true,
          repeat: false,
          shimmerColor: AppThemeHSL.textPrimary,
          child: SummaryCard(
            userName: 'Arees',
            onCloseTap: () => setState(() => _welcomeSummaryCardShown = false),
            onDetailsTap: () {},
          ),
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

  // --- MÉTODOS DE ACCIÓN ---
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
                            child: StatisticsScreen(transactions: transactions),
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
    );
  }
}
