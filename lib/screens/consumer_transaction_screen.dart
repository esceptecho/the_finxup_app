import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/list_notifier.dart';
import 'package:the_finxup_app/providers/new_financial_summary_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/repositories/hive_repository.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_transaction_form.dart';
import 'package:the_finxup_app/widgets/bill_card.dart';
import 'package:the_finxup_app/widgets/slidable_item.dart';
import 'package:the_finxup_app/widgets/transaction_card.dart';

class ConsumerTransactionsScreen extends ConsumerStatefulWidget {
  final bool openAddModal; // Parámetro para abrir el modal automáticamente
  const ConsumerTransactionsScreen({super.key, this.openAddModal = false});

  @override
  ConsumerState<ConsumerTransactionsScreen> createState() =>
      _ConsumerTransactionsScreenState();
}

class _ConsumerTransactionsScreenState
    extends ConsumerState<ConsumerTransactionsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'transactions'; // 'transactions' o 'invoices'
  bool get _isShowingTransactions => _selectedCategory == 'transactions';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool showTAnimatedTextKit = true;

  // Paleta de colores
  static const Color wineColor = Color(0xFF722F37); // Vino tinto
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

    // 2. Abrir modal automáticamente si se solicita
    if (widget.openAddModal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAddCardModal(context);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
        _animationController.reset();
        _animationController.forward();
      });
    }
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
      // mini: true,
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
    // final transactionList = ref.watch(filteredTransactionsProvider);
    // final isExpanded = ref.watch(listProvider.select((s) => s.isExpanded));
    final billsList = ref.watch(billListNotifierProvider).value ?? [];
    final summary = ref.watch(financialSummaryProvider);

    final transactionListAsync = ref.watch(transactionListNotifierProvider);
    final transactions = transactionListAsync.value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text(
          'Mis Finanzas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Tarjeta de resumen
            _buildSummaryCard(
              balance: summary.balance,
              income: summary.income,
              expense: summary.expense,
              percentage: summary.percentage,
            ),
            const SizedBox(height: 24),
            // Selector de categorías
            ConsumerCategoryFilterSelector(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
            const SizedBox(height: 16),
            // Lista de items
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
            // if (_isShowingTransactions)
            //   _buildExpansionButton(isExpanded),
            // const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(summary.percentage),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  // Widget _buildExpansionButton(bool isExpanded) {
  //   return TextButton.icon(
  //     onPressed: () => ref.read(listProvider.notifier).toggleExpansion(),
  //     icon: Icon(
  //       isExpanded ? Icons.expand_less : Icons.expand_more,
  //       color: AppThemeHSL.textDisabled,
  //     ),
  //     label: Text(
  //       isExpanded ? "Mostrar menos" : "Ver más",
  //       style: TextStyle(color: AppThemeHSL.textDisabled, fontSize: 16),
  //     ),
  //   );
  // }

  Widget _buildSummaryCard({
    required double balance,
    required double expense,
    required double income,
    required double percentage,
  }) {
    final billsList = ref.watch(billListNotifierProvider).value ?? [];
    final transactionList = ref.watch(filteredTransactionsProvider);
    // final summary = ref.watch(financialSummaryProvider);
    // final percentage = summary.percentage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
                        SizedBox(width: 4),
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
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  showTAnimatedTextKit
                      ? Expanded(
                          child: SizedBox(
                            height: 70,
                            child: Column(
                              mainAxisAlignment: .center,
                              crossAxisAlignment: .end,
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
                                      speed: const Duration(milliseconds: 100),
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
                                      speed: const Duration(milliseconds: 100),
                                    ),
                                    TypewriterAnimatedText(
                                      "${(percentage.toStringAsFixed(2))}% es  tu balance restante.",
                                      textStyle: TextStyle(
                                        color: AppThemeHSL.textSecondary
                                            .withValues(alpha: 0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      speed: const Duration(milliseconds: 100),
                                    ),
                                    TypewriterAnimatedText(
                                      "\$${(income)} son el total de ingresos.",
                                      textStyle: TextStyle(
                                        color: AppThemeHSL.textSecondary
                                            .withValues(alpha: 0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      speed: const Duration(milliseconds: 100),
                                    ),
                                    TypewriterAnimatedText(
                                      "\$${(expense)} es el total gastado.",
                                      textStyle: TextStyle(
                                        color: AppThemeHSL.textSecondary
                                            .withValues(alpha: 0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      speed: const Duration(milliseconds: 100),
                                    ),

                                    TypewriterAnimatedText(
                                      "Esconder 👇",
                                      textStyle: TextStyle(
                                        color: AppThemeHSL.textSecondary
                                            .withValues(alpha: 0.9),
                                        fontSize: 18,
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
                        )
                      : SizedBox.shrink(),
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
          mainAxisSize: .min,
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      shrinkWrap: true,
      itemCount: items.length,
      // ✅ CORRECTO
      itemBuilder: (context, index) {
        final item = items[index];
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
            onDelete: () => _deleteBill(item.id),
            onToggleStatus: () => _markBillAsPaid(item),
            child: BillCard(bill: item, isPaid: false),
          );
        }
        return null;
      }
    );
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
