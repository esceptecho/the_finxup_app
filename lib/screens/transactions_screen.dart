import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedFilter = 'transactions'; // 'transactions' o 'invoices'

  // Paleta de colores
  static const Color wineColor = Color(0xFF722F37); // Vino tinto
  static const Color darkWineColor = Color(0xFF4A1D24);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color lightGoldColor = Color(0xFFFFF8DC);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF2D2D2D);
  static const Color surfaceColor = Color(0xFF252525);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkWineColor,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: goldColor),
            SizedBox(width: 12),
            Text(
              'Mis Finanzas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: goldColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarjeta de resumen
          _buildSummaryCard(),

          const SizedBox(height: 20),

          // CategoryFilterSelector
          _buildCategoryFilterSelector(),

          const SizedBox(height: 16),

          // Lista de items
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [wineColor, darkWineColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: wineColor.withOpacity(0.4),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Total',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$45,280.50',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: goldColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.arrow_downward,
                  label: 'Ingresos',
                  amount: '\$28,450.00',
                  color: Colors.greenAccent,
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem(
                  icon: Icons.arrow_upward,
                  label: 'Gastos',
                  amount: '\$16,830.50',
                  color: Colors.orangeAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goldColor.withOpacity(0.3), width: 1),
        ),
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
            Container(width: 1, height: 32, color: goldColor.withOpacity(0.3)),
            Expanded(
              child: _buildFilterButton(
                label: 'Facturas',
                icon: Icons.receipt_long,
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
      ),
    );
  }

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
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [wineColor, darkWineColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: wineColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? goldColor : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: ListView.builder(
        key: ValueKey<String>(_selectedFilter),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildListItem(index);
        },
      ),
    );
  }

  Widget _buildListItem(int index) {
    final isEven = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: wineColor.withOpacity(0.3),
          highlightColor: wineColor.withOpacity(0.1),
          onTap: () {
            // Acción al seleccionar item
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de categoría
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isEven
                          ? [
                              wineColor.withOpacity(0.8),
                              darkWineColor.withOpacity(0.8),
                            ]
                          : [
                              goldColor.withOpacity(0.3),
                              goldColor.withOpacity(0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isEven ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isEven ? Colors.greenAccent : Colors.orangeAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Información de la transacción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFilter == 'transactions'
                            ? 'Transacción #${index + 1}'
                            : 'Factura #${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Descripción de la operación',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Monto y fecha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isEven ? '+\$2,450.00' : '-\$890.00',
                      style: TextStyle(
                        color: isEven
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hoy 14:30',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
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
}
