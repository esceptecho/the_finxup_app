import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_filter_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/resumen_cards.dart';
import 'package:the_finxup_app/widgets/transaction_history_card.dart';

class HistoricoTransaccionesScreen extends ConsumerWidget {
  const HistoricoTransaccionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListNotifierProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final filtroActual = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: AppThemeHSL.background,

      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(transactionListNotifierProvider);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay transacciones',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primera transacción',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Resumen histórico (siempre visible)
                const ResumenHistoricoWidget(),

                const SizedBox(height: 16),

                // Filtros
                const FiltroTransaccionesWidget(),

                // Contador de resultados
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12,),
                  child: Row(
                    children: [
                      Text(
                        '${filteredTransactions.length} transacciones',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // const Spacer(),
                      if (filtroActual != TransactionFilter.all)
                        TextButton.icon(
                          onPressed: () {
                            ref.read(transactionFilterProvider.notifier).state =
                                TransactionFilter.all;
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Limpiar filtro'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),

                // Lista filtrada
                if (filteredTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          filtroActual == TransactionFilter.income
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filtroActual == TransactionFilter.income
                              ? 'No hay ingresos registrados'
                              : 'No hay gastos registrados',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // ⚠️ IMPORTANTE: Quitamos Expanded y envolvemos en SizedBox
                  ListView.builder(
                    padding: EdgeInsets.only(top: 4),
                    shrinkWrap: true, // 👈 ESTO ES CLAVE
                    physics:
                        const NeverScrollableScrollPhysics(), // 👈 Evita conflicto de scroll
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      return TransactionHistoricoCard(
                        transaction: filteredTransactions[index],
                      );
                    },
                  ),

                // Espacio para el FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a la pantalla de agregar transacción
          // Navigator.push(context, MaterialPageRoute(...));
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
        backgroundColor: AppThemeHSL.primaryDark,
      ),
    );
  }
}

class TransactionHistoricoCompactCard extends ConsumerWidget {
  final Transaction transaction;

  const TransactionHistoricoCompactCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final valorHistorico = transaction.totalAccumulatedValue;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isExpense
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        child: Icon(
          IconData(transaction.iconCodePoint, fontFamily: 'MaterialIcons'),
          color: isExpense ? Colors.red : Colors.green,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${transaction.categoryDisplay} • ${DateFormat('dd/MM/yy').format(transaction.date)}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (transaction.recurrence != 'Única vez')
            Text(
              'Total: \$${valorHistorico.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                color: isExpense ? Colors.red.shade400 : Colors.green.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// class TransactionListScreen extends ConsumerWidget {
//   const TransactionListScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final transactionsAsync = ref.watch(transactionListNotifierProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Mis Transacciones')),
//       body: transactionsAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//         data: (transactions) {
//           if (transactions.isEmpty) {
//             return const Center(child: Text('No hay transacciones'));
//           }

//           return Column(
//             children: [
//               // Widget del saldo total
//               const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: SaldoTotalHistoricoWidget(),
//               ),

//               // Lista de transacciones con su valor histórico
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: transactions.length,
//                   itemBuilder: (context, index) {
//                     return TransactionHistoricoCard(
//                       transaction: transactions[index],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
