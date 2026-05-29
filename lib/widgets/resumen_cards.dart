// Tarjeta de resumen reutilizable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/transaction_filter_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class ResumenCard extends StatelessWidget {
  final String titulo;
  final double monto;
  final Color color;
  final IconData icon;

  const ResumenCard({
    super.key,
    required this.titulo,
    required this.monto,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if(titulo == 'INGRESOS')
                Icon(icon, color: AppThemeHSL.incomeLight, size: 20),
                if (titulo == 'GASTOS')
                Icon(icon, color: AppThemeHSL.expenseLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    color: AppThemeHSL.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 12),
            Text(
              '\$${monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppThemeHSL.textSecondary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de las 3 tarjetas de resumen
class ResumenHistoricoWidget extends ConsumerWidget {
  const ResumenHistoricoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingresos = ref.watch(totalIngresosHistoricosProvider);
    final gastos = ref.watch(totalGastosHistoricosProvider);
    final balance = ref.watch(balanceHistoricoProvider);

    return Column(
      children: [
        // Balance general (tarjeta más grande)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(right: 12, left: 12, top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppThemeHSL.surfaceMid, AppThemeHSL.surfaceLighter]
            ),
            borderRadius: BorderRadius.circular(7),
            // boxShadow: [
              // BoxShadow(
              //   color: (balance >= 0 ? Colors.teal : Colors.red).withValues(
              //     alpha: 0.3,
              //   ),
              //   blurRadius: 10,
              //   offset: const Offset(0, 5),
              // ),
            // ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    balance >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: balance >= 0 ? AppThemeHSL.income : AppThemeHSL.expense,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BALANCE HISTÓRICO',
                    style: TextStyle(
                      color:AppThemeHSL.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '\$${balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: balance >= 0
                      ? AppThemeHSL.income
                      : AppThemeHSL.expense,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                balance >= 0 ? 'A favor' : 'En contra',
                style: TextStyle(
                  color: AppThemeHSL.textSecondary.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Ingresos y Gastos lado a lado
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: ResumenCard(
                  titulo: 'INGRESOS',
                  monto: ingresos,
                  color: AppThemeHSL.surfaceLighter,
                  icon: Icons.arrow_downward,
                ),
              ),
              Expanded(
                child: ResumenCard(
                  titulo: 'GASTOS',
                  monto: gastos,
                  color: AppThemeHSL.surfaceLighter,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FiltroTransaccionesWidget extends ConsumerWidget {
  const FiltroTransaccionesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtroActual = ref.watch(transactionFilterProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeHSL.surfaceLighter,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            ref,
            label: 'Todos',
            icon: Icons.list_alt,
            filter: TransactionFilter.all,
            isSelected: filtroActual == TransactionFilter.all,
            color: AppThemeHSL.accentGold.withValues(alpha: 0.7),
          ),
          _buildFilterChip(
            context,
            ref,
            label: 'Ingresos',
            icon: Icons.trending_up,
            filter: TransactionFilter.income,
            isSelected: filtroActual == TransactionFilter.income,
            color: AppThemeHSL.incomeDark,
          ),
          _buildFilterChip(
            context,
            ref,
            label: 'Gastos',
            icon: Icons.trending_down,
            filter: TransactionFilter.expense,
            isSelected: filtroActual == TransactionFilter.expense,
            color: AppThemeHSL.expense,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required TransactionFilter filter,
    required bool isSelected,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            ref.read(transactionFilterProvider.notifier).state = filter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppThemeHSL.textHint,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
