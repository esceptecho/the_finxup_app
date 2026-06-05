import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/providers/debts_filter_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DebtConsumerListTableDialog extends StatelessWidget {
  const DebtConsumerListTableDialog({super.key, required this.dateFormat});

  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Escuchamos la lista ya filtrada por Texto y por Categoria del Dropdown
        final filteredDebts = ref.watch(filteredDebtsProvider);
        final double width90Percent = MediaQuery.of(context).size.width * 0.90;

        return AlertDialog(
          backgroundColor: AppThemeHSL.surfaceMid,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'Registro de Deudas',
                    style: TextStyle(
                      color: AppThemeHSL.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(
                        color: AppThemeHSL.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Resultados basados en tus filtros activos.',
                style: TextStyle(
                  color: AppThemeHSL.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: width90Percent,
            //  height: 380, // Altura máxima compacta
            child: filteredDebts.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron registros.',
                      style: TextStyle(color: AppThemeHSL.textMuted),
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dataTableTheme: DataTableThemeData(
                              horizontalMargin: 10,
                              columnSpacing: 14,
                            ),
                          ),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              AppThemeHSL.surfaceLight,
                            ),
                            headingRowHeight: 34,
                            dataRowMinHeight: 32,
                            dataRowMaxHeight: 38,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Nombre',
                                  style: TextStyle(
                                    color: AppThemeHSL.accentGoldSoft,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Cantidad',
                                  style: TextStyle(
                                    color: AppThemeHSL.accentGoldSoft,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Fecha',
                                  style: TextStyle(
                                    color: AppThemeHSL.accentGoldSoft,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Tipo',
                                  style: TextStyle(
                                    color: AppThemeHSL.accentGoldSoft,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Estado',
                                  style: TextStyle(
                                    color: AppThemeHSL.accentGoldSoft,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: filteredDebts.map((debt) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      debt.nombre,
                                      style: TextStyle(
                                        color: AppThemeHSL.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '\$${debt.cantidad.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppThemeHSL.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      dateFormat.format(debt.fecha),
                                      style: TextStyle(
                                        color: AppThemeHSL.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      debt.esDeuda ? 'Debes 🔴' : 'Te deben 🟢',
                                      style: TextStyle(
                                        color: debt.esDeuda
                                            ? AppThemeHSL.expenseLight
                                            : AppThemeHSL.incomeLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: debt.pagado
                                            ? AppThemeHSL.incomeDark
                                            : AppThemeHSL.expenseDark,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        debt.pagado ? 'Pagado' : 'Pendiente',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
