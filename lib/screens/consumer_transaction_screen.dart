import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/list_notifier.dart';
import 'package:the_finxup_app/providers/financial_summary_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_transaction_form.dart';
import 'package:the_finxup_app/widgets/bill_card.dart';
import 'package:the_finxup_app/widgets/slidable_item.dart';
import 'package:the_finxup_app/widgets/transaction_card.dart';

class ConsumerTransactionsScreen extends ConsumerStatefulWidget {
  final bool openAddModal;
  final String? focusBillId; // Puede ser ID de factura o transacción
  final String? heroTag;
  const ConsumerTransactionsScreen({
    super.key,
    this.openAddModal = false,
    this.focusBillId,
    this.heroTag,
  });

  @override
  ConsumerState<ConsumerTransactionsScreen> createState() =>
      _ConsumerTransactionsScreenState();
}

class _ConsumerTransactionsScreenState
    extends ConsumerState<ConsumerTransactionsScreen>
    with SingleTickerProviderStateMixin {
  // CORREGIDO: No la inicializamos estática. Se determinará de forma dinámica en el initState.
  late String _selectedCategory;
  bool get _isShowingTransactions => _selectedCategory == 'transactions';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool showTAnimatedTextKit = true;

  late FixedExtentScrollController _wheelController;
  int _selectedIndex = 0;

  // Bandera de control para ejecutar el scroll automático una única vez al entrar
  bool _hasScrolledToFocus = false;

  static const Color wineColor = Color(0xFF722F37);
  static const Color darkWineColor = Color(0xFF4A1D24);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    if (widget.openAddModal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAddCardModal(context);
      });
    }

    // 1. DETERMINAR PESTAÑA Y OFFSET INICIAL (SÍNCRONO DESDE EL CACHÉ)
    _selectedCategory = 'transactions'; // Valor por defecto seguro
    int initialIndex = 0;

    if (widget.focusBillId != null) {
      final bills = ref.read(billListNotifierProvider).value ?? [];
      final txs = ref.read(transactionListNotifierProvider).value ?? [];

      // Buscar si el ID pertenece a una factura
      final billIndex = bills.indexWhere((b) => b.id == widget.focusBillId);
      // Buscar si el ID pertenece a una transacción
      final txIndex = txs.indexWhere((t) => t.id == widget.focusBillId);

      if (billIndex != -1) {
        _selectedCategory = 'invoices';
        initialIndex = billIndex;
        _selectedIndex = billIndex;
        _hasScrolledToFocus = true; // Ya lo posicionamos con éxito
      } else if (txIndex != -1) {
        _selectedCategory = 'transactions';
        initialIndex = txIndex;
        _selectedIndex = txIndex;
        _hasScrolledToFocus = true; // Ya lo posicionamos con éxito
      } else {
        // Si no está en caché aún porque está cargando de forma asíncrona,
        // por defecto asumimos que si viene de Bill Management va a invoices.
        _selectedCategory = 'invoices';
      }
    }

    _wheelController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _wheelController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
        _selectedIndex = 0; // Resetear índice visual al cambiar de pestaña
        _animationController.reset();
        _animationController.forward();
      });
      // Mover la rueda al primer elemento de la nueva pestaña de forma segura
      if (_wheelController.hasClients) {
        _wheelController.jumpToItem(0);
      }
    }
  }

  void _markBillAsPaid(Bill bill) async {
    final tx = Transaction(
      description: "Pago: ${bill.title}",
      amount: bill.amount,
      type: TransactionType.expense,
      date: DateTime.now(),
      iconCodePoint: Icons.check_circle.codePoint,
    );

    await ref.read(transactionListNotifierProvider.notifier).addTransaction(tx);
    await ref.read(billListNotifierProvider.notifier).delete(bill.id);
  }

  void _deleteTransaction(String id) {
    ref.read(transactionListNotifierProvider.notifier).deleteTransaction(id);
  }

  void _deleteBill(String id) {
    ref.read(billListNotifierProvider.notifier).delete(id);
  }

  void showAddCardModal(BuildContext context) {
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

  Widget _buildFAB(double percentage) {
    return FloatingActionButton(
      onPressed: () => showAddCardModal(context),
      backgroundColor: wineColor,
      elevation: 4,
      heroTag: percentage,
      enableFeedback: true,
      child: Icon(Icons.add, color: AppThemeHSL.textPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billsList = ref.watch(billListNotifierProvider).value ?? [];
    final summary = ref.watch(financialSummaryProvider);
    final transactionListAsync = ref.watch(transactionListNotifierProvider);
    final transactions = transactionListAsync.value ?? [];

    // 2. CONTROLADOR ASÍNCRONO POST-RENDER (Si los datos tardaron en cargar)
    // 2. CONTROLADOR ASÍNCRONO POST-RENDER (Modificado para deslizamiento lento)
    if (widget.focusBillId != null && !_hasScrolledToFocus) {
      final bIndex = billsList.indexWhere((b) => b.id == widget.focusBillId);
      final tIndex = transactions.indexWhere((t) => t.id == widget.focusBillId);

      if (bIndex != -1) {
        _hasScrolledToFocus = true;
        _selectedCategory = 'invoices';
        _selectedIndex = bIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            // Espera a que termine la transición de pantallas
            if (_wheelController.hasClients) {
              _wheelController.animateToItem(
                bIndex,
                duration: const Duration(
                  milliseconds: 1000,
                ), // 1 segundo completo de giro sutil
                curve: Curves.linearToEaseOut,
              );
            }
          });
        });
      } else if (tIndex != -1) {
        _hasScrolledToFocus = true;
        _selectedCategory = 'transactions';
        _selectedIndex = tIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_wheelController.hasClients) {
            // CAMBIADO: animateToItem en lugar de jumpToItem
            _wheelController.animateToItem(
              tIndex,
              duration: const Duration(
                seconds: 4,
              ), // <-- Controla la velocidad aquí
              curve: Curves.easeInOutCubic,
            );
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSummaryCard(
            balance: summary.balance,
            income: summary.income,
            expense: summary.expense,
            percentage: summary.percentage,
          ),
          const SizedBox(height: 24),
          ConsumerCategoryFilterSelector(
            selectedCategory: _selectedCategory,
            onCategoryChanged: _onCategoryChanged,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildItemsList(
                isShowingTransactions: _isShowingTransactions,
                transactions: transactions,
                bills: billsList,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(summary.percentage),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildSummaryCard({
    required double balance,
    required double expense,
    required double income,
    required double percentage,
  }) {
    final billsList = ref.watch(billListNotifierProvider).value ?? [];
    final transactionList = ref.watch(filteredTransactionsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [wineColor, darkWineColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: AppThemeHSL.primaryDark.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Balance Total',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: percentage > 0
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            percentage > 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: percentage > 0
                                ? AppThemeHSL.incomeLight
                                : AppThemeHSL.expenseLight,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            CurrencyFormatter.formatPercentage(percentage),
                            style: TextStyle(
                              color: percentage > 0
                                  ? AppThemeHSL.incomeLight
                                  : AppThemeHSL.expenseLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        CurrencyFormatter.formatAmount(balance),
                        style: TextStyle(
                          color: balance > 0
                              ? AppThemeHSL.incomeLight
                              : AppThemeHSL.expenseLight,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    showTAnimatedTextKit
                        ? Expanded(
                            child: SizedBox(
                              height: 70,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AnimatedTextKit(
                                    onTap: () {
                                      setState(() {
                                        showTAnimatedTextKit =
                                            !showTAnimatedTextKit;
                                      });
                                    },
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        "Tienes ${(billsList.length)} facturas pendientes.",
                                        textStyle: TextStyle(
                                          color: AppThemeHSL.textSecondary
                                              .withValues(alpha: 0.9),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                      ),
                                      TypewriterAnimatedText(
                                        transactionList.isEmpty
                                            ? "No hay transacciones"
                                            : transactionList.length == 1
                                            ? "${transactionList.length} transacción en total."
                                            : "${transactionList.length} transacciones en total.",
                                        textStyle: TextStyle(
                                          color: AppThemeHSL.textSecondary
                                              .withValues(alpha: 0.9),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                      ),
                                      TypewriterAnimatedText(
                                        "${(percentage.toStringAsFixed(2))}% es tu balance restante.",
                                        textStyle: TextStyle(
                                          color: AppThemeHSL.textSecondary
                                              .withValues(alpha: 0.9),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                      ),
                                      TypewriterAnimatedText(
                                        "\$${(income)} son el total de ingresos.",
                                        textStyle: TextStyle(
                                          color: AppThemeHSL.textSecondary
                                              .withValues(alpha: 0.9),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                      ),
                                      TypewriterAnimatedText(
                                        "\$${(expense)} es el total gastado.",
                                        textStyle: TextStyle(
                                          color: AppThemeHSL.textSecondary
                                              .withValues(alpha: 0.9),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                      ),
                                      TypewriterAnimatedText(
                                        "Esconder 👇",
                                        textStyle: TextStyle(
                                          color: AppThemeHSL.textSecondary
                                              .withValues(alpha: 0.9),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                      ),
                                    ],
                                    isRepeatingAnimation: false,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.arrow_upward,
                      iconColor: AppThemeHSL.accentGold,
                      label: 'Gastos',
                      amount: CurrencyFormatter.formatAmount(expense),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildSummaryItem(
                      icon: Icons.arrow_downward,
                      iconColor: AppThemeHSL.incomeLight,
                      label: 'Ingresos',
                      amount: CurrencyFormatter.formatAmount(income),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList({
    required bool isShowingTransactions,
    required List<Transaction> transactions,
    required List<Bill> bills,
  }) {
    final items = isShowingTransactions ? transactions : bills;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedCategory == 'transactions'
                  ? Icons.description_outlined
                  : Icons.receipt_long_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ${_selectedCategory == 'transactions' ? 'transacciones' : 'facturas'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListWheelScrollView.useDelegate(
      controller: _wheelController,
      itemExtent: 170,
      diameterRatio: 1.5,
      perspective: 0.003,
      squeeze: 1.0,
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
        final selectedItem = items[index];
        print('Item seleccionado: $selectedItem');
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index >= items.length) return const SizedBox.shrink();

          final item = items[index];
          final isSelected = index == _selectedIndex;

          final String? itemId = (item as dynamic).id;
          final isFocused = itemId == widget.focusBillId;

          Widget cardChild = _buildItemContent(item);

          if (isFocused && widget.heroTag != null) {
            cardChild = Hero(
              tag: widget.heroTag!,
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
              child: Material(color: Colors.transparent, child: cardChild),
            );
          }

          return AnimatedScale(
            scale: isSelected ? 1.0 : 0.85,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.7,
              duration: const Duration(milliseconds: 200),
              child: cardChild,
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  // Nota: Asegúrate de tener implementado tu método original para renderizar las tarjetas internas
  Widget _buildItemContent(dynamic item) {
    if (item is Transaction) {
      return SlidableItem(
        onDelete: () async {
          await Future.delayed(const Duration(milliseconds: 300));
          _deleteTransaction(item.id);
        },
        child: TransactionCard(transaction: item),
      );
    } else if (item is Bill) {
      return SlidableItem(
        //
        onDelete: () => _deleteBill(item.id),
        onToggleStatus: () => _markBillAsPaid(item),
        child: BillCard(bill: item, isPaid: false),
      );
    }
    return const SizedBox.shrink();
  }
}

class ConsumerCategoryFilterSelector extends ConsumerStatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const ConsumerCategoryFilterSelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  ConsumerState<ConsumerCategoryFilterSelector> createState() =>
      _ConsumerCategoryFilterSelectorState();
}

class _ConsumerCategoryFilterSelectorState
    extends ConsumerState<ConsumerCategoryFilterSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => widget.onCategoryChanged('transactions'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.selectedCategory == 'transactions'
                        ? AppThemeHSL.primaryExtraLight.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: widget.selectedCategory == 'transactions'
                        ? [
                            BoxShadow(
                              color: AppThemeHSL.background.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 20,
                          color: widget.selectedCategory == 'transactions'
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Transacciones',
                          style: TextStyle(
                            color: widget.selectedCategory == 'transactions'
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => widget.onCategoryChanged('invoices'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.selectedCategory == 'invoices'
                        ? AppThemeHSL.primaryExtraLight.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: widget.selectedCategory == 'invoices'
                        ? [
                            BoxShadow(
                              color: AppThemeHSL.background.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 20,
                          color: widget.selectedCategory == 'invoices'
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Facturas',
                          style: TextStyle(
                            color: widget.selectedCategory == 'invoices'
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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
    );
  }
}
