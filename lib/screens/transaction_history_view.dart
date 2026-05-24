import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/list_notifier.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class TransactionHistoryView extends ConsumerStatefulWidget {
  const TransactionHistoryView({super.key});

  @override
  ConsumerState<TransactionHistoryView> createState() =>
      _TransactionHistoryViewtate();
}

class _TransactionHistoryViewtate
    extends ConsumerState<TransactionHistoryView> {
  @override
  Widget build(BuildContext context) {
    // Obtenemos solo la lista ya procesada (ordenada y limitada)
    final transactions = ref.watch(filteredTransactionsProvider);
    // Necesitamos el estado para saber si el botón dice "Ver más" o "Ver menos"
    final isExpanded = ref.watch(listProvider.select((s) => s.isExpanded));

    if (transactions.isEmpty) {
      return const Center(child: Text("No hay transacciones"));
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return Dismissible(
              background: Container(
                color: Colors.redAccent,
                child: Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.black87,
                  size: 32,
                ),
              ),
              onDismissed: (direction) {
                print('Eliminando $index');
                setState(() {});
              },
              key: UniqueKey(),
              child: ListTile(
                leading: Icon(
                  IconData(tx.iconCodePoint, fontFamily: 'MaterialIcons'),
                ),
                title: Text(tx.description),
                subtitle: Text(
                  "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                ),
                trailing: Text(
                  "${tx.amount.toStringAsFixed(2)}\$",
                  style: TextStyle(
                    color: tx.type == TransactionType.expense
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        TextButton.icon(
          onPressed: () => ref.read(listProvider.notifier).toggleExpansion(),
          icon: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppThemeHSL.accentGold,
          ),
          label: Text(
            isExpanded ? "Mostrar menos" : "Ver últimas transacciones",
            style: TextStyle(color: AppThemeHSL.accentGold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
