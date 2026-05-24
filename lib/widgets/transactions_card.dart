import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/screens/transaction_detail_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
// Importa tu modelo Transaction

class TransactionsCard extends StatelessWidget {
  final Transaction transaction;
  // Opcional: callback por si quieres mantener la funcionalidad de añadir al calendario
  final VoidCallback? onAddReminder;

  const TransactionsCard({
    super.key,
    required this.transaction,
    this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    // Asumimos que TransactionType es un enum y validamos si es un ingreso
    // (Ajusta 'income' por el valor real de tu enum)
    final bool isIncome = transaction.type.toString().contains('income');

    return Hero(
      // El ID único asegura que Flutter sepa exactamente qué tarjeta animar
      tag: 'tx_hero_${transaction.id}',
      child: Material(
        type: MaterialType
            .transparency, // Evita fallos de renderizado en el texto
        child: InkWell(
          onTap: () {
            // Aquí navegas a tu pantalla de detalle. Ejemplo:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TransactionDetailScreen(transaction: transaction),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeHSL.surface,
              borderRadius: BorderRadius.circular(0.0),
              border: Border.all(
                color: isIncome
                    ? AppThemeHSL.income.withValues(alpha: 0.1)
                    : AppThemeHSL.expense.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                // Icono de la transacción
                InkWell(
                  onTap:
                      onAddReminder, // Puedes seguir usando add_2_calendar aquí
                  onDoubleTap: () {},
                  child: CircleAvatar(
                    backgroundColor: isIncome
                        ? AppThemeHSL.income.withValues(alpha: 0.2)
                        : AppThemeHSL.expenseDark.withValues(alpha: 0.2),
                    child: Icon(
                      // Convertimos el codePoint de nuevo a IconData
                      IconData(
                        transaction.iconCodePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: isIncome
                          ? AppThemeHSL.income
                          : AppThemeHSL.expense,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Detalles (Descripción, Subcategoría y Fecha)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monto
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinea el monto arriba si hay varias líneas
                        children: [
                          Expanded(
                            // <--- Crucial para que el texto sepa dónde detenerse
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description,
                                  style: TextStyle(
                                    color: AppThemeHSL.textPrimary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  // Quitamos el maxLines: 1 para que pueda bajar
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ), // Espacio de seguridad entre texto y monto
                          Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isIncome
                                  ? AppThemeHSL.income
                                  : AppThemeHSL.expense,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Mostrar Subcategoría solo si existe
                      if (transaction.subCategory != null)
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              transaction.categoryDisplay.toUpperCase(),
                              style: TextStyle(
                                color: AppThemeHSL.textPrimary.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
