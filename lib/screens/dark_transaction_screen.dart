import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DarkTransactionsScreen extends ConsumerStatefulWidget {
  const DarkTransactionsScreen({super.key});

  @override
  ConsumerState<DarkTransactionsScreen> createState() => _DarkTransactionsScreenState();
}

class _DarkTransactionsScreenState extends ConsumerState<DarkTransactionsScreen> {
  String _selectedFilter = 'transactions'; // 'transactions' o 'invoices'

// Paleta de colores
  static const Color wineColor = Color(0xFF722F37); // Vino tinto
  static const Color darkWineColor = Color(0xFF4A1D24);

  // Datos de ejemplo para el resumen
  final Map<String, dynamic> _summaryData = {
    'totalTransactions': 1245000.00,
    'totalInvoices': 24,
    'pendingPayments': 350000.00,
    'currency': 'USD',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeHSL.backgroundDeep,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppThemeHSL.background,
        title: const Text(
          'Mis Movimientos',
          style: TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white54),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            onPressed: () {
              // Más opciones
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarjeta de Resumen Superior
          _buildSummaryCard(),

          const SizedBox(height: 20),

          // Selector de Filtro por Categoría
          _buildCategoryFilterSelector(),

          const SizedBox(height: 16),

          // Lista de Items
          Expanded(child: _buildTransactionsList()),
        ],
      ),
    );
  }

  // Widget para la tarjeta de resumen
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [wineColor, darkWineColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: darkWineColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resumen General',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Este mes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    icon: Icons.arrow_upward,
                    label: 'Ingresos',
                    amount:
                        '\$${_summaryData['totalTransactions'].toStringAsFixed(2)}',
                    color: const Color(0xFF2ED573),
                  ),
                  _buildSummaryItem(
                    icon: Icons.arrow_downward,
                    label: 'Pendientes',
                    amount:
                        '\$${_summaryData['pendingPayments'].toStringAsFixed(2)}',
                    color: const Color(0xFFFFA502),
                  ),
                  _buildSummaryItem(
                    icon: Icons.receipt_long,
                    label: 'Facturas',
                    amount: '${_summaryData['totalInvoices']}',
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para cada item del resumen
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Widget para el selector de filtro por categoría
  Widget _buildCategoryFilterSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              label: 'Transacciones',
              icon: Icons.swap_horiz,
              isSelected: _selectedFilter == 'transactions',
              onTap: () {
                setState(() {
                  _selectedFilter = 'transactions';
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterButton(
              label: 'Facturas',
              icon: Icons.description_outlined,
              isSelected: _selectedFilter == 'invoices',
              onTap: () {
                setState(() {
                  _selectedFilter = 'invoices';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Botón individual para el filtro
  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? wineColor : AppThemeHSL.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? wineColor
                : AppThemeHSL.surfaceLighter,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: wineColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF666666),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF666666),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la lista de transacciones/facturas
  Widget _buildTransactionsList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey<String>(_selectedFilter),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 8, // Número de ejemplo
        itemBuilder: (context, index) {
          return _buildTransactionTile(index);
        },
      ),
    );
  }

  // Widget para cada tile de la lista
  Widget _buildTransactionTile(int index) {
    final isTransaction = _selectedFilter == 'transactions';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppThemeHSL.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Navegar al detalle
              print(
                '${isTransaction ? "Transacción" : "Factura"} seleccionada: $index',
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono del tipo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isTransaction
                          ? const Color(0xFF2ED573).withValues(alpha: 0.1)
                          : const Color(0xFFFFA502).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isTransaction ? Icons.swap_horiz : Icons.receipt_long,
                      color: isTransaction
                          ? const Color(0xFF2ED573)
                          : const Color(0xFFFFA502),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTransaction
                              ? 'Transacción #${1000 + index}'
                              : 'Factura #${2000 + index}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTransaction ? 'Pago recibido' : 'Factura emitida',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Monto y flecha
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${(index + 1) * 1250}.00',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isTransaction
                              ? const Color(0xFF2ED573)
                              : const Color(0xFFFFA502),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}/2024',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
