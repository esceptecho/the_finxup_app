import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Asegúrate de tener la dependencia
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/providers/new_financial_summary_provider.dart';
import 'package:the_finxup_app/screens/debt_detail_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DsDebtCardItem extends ConsumerWidget {
  final Debt debt;
  final VoidCallback onCheckChanged;
  final VoidCallback onDelete;

  const DsDebtCardItem({
    super.key,
    required this.debt,
    required this.onCheckChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cantidadFormateada = CurrencyFormatter.formatDebt(debt.cantidad);
    final pendienteFormateada = CurrencyFormatter.formatDebt(
      debt.montoRestante,
    );
    final porcentaje = debt.porcentajePagado;
    final estaVencido =
        debt.fechaVencimiento != null &&
        debt.fechaVencimiento!.isBefore(DateTime.now()) &&
        !debt.pagado &&
        debt.montoRestante > 0;

    final Color accentColor;
    if (debt.pagado) {
      accentColor = Colors.greenAccent;
    } else if (estaVencido) {
      accentColor = Colors.redAccent;
    } else if (debt.montoRestante < debt.cantidad && porcentaje > 0) {
      accentColor = Colors.orangeAccent;
    } else {
      accentColor = debt.esDeuda ? Colors.redAccent : Colors.greenAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          key: ValueKey(debt.id),
          // Menú de acciones que aparece al deslizar de derecha a izquierda
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.5, // Controla qué tan ancho es el menú de acciones
            children: [
              // Acción: Completar / Desmarcar
              SlidableAction(
                onPressed: (_) => onCheckChanged(),
                backgroundColor: debt.pagado ? Colors.blueGrey : Colors.green,
                foregroundColor: Colors.white,
                icon: debt.pagado ? Icons.undo_rounded : Icons.check_rounded,
                label: debt.pagado ? 'Pendiente' : 'Completar',
              ),
              // Acción: Borrar
              SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
                label: 'Borrar',
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeHSL.surface,
              border: Border(
                left: BorderSide(
                  color: accentColor.withValues(alpha: 0.6),
                  width: 3,
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Cambiado a onTap para mejorar la UX estándar
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DebtDetailScreen(
                        debt: debt,
                        onUpdate: (updatedDebt) {},
                        onDelete: () async {
                          await ref
                              .read(debtListProvider.notifier)
                              .deleteDebt(debt.id);
                        },
                      ),
                    ),
                  );
                },
                splashColor: accentColor.withValues(alpha: 0.05),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // FILA SUPERIOR (Ahora más limpia sin el Checkbox)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  debt.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: debt.pagado
                                        ? Colors.white38
                                        : Colors.white,
                                    decoration: debt.pagado
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (debt.categoria != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    debt.categoria!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${debt.currencyType.symbol}$cantidadFormateada',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: debt.pagado
                                      ? Colors.white30
                                      : Colors.white,
                                ),
                              ),
                              if (debt.montoRestante != debt.cantidad &&
                                  !debt.pagado)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Faltan ${debt.currencyType.symbol}$pendienteFormateada',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white38,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // El Checkbox y su SizedBox intermedio han sido eliminados por completo
                        ],
                      ),

                      // Barra de progreso
                      if (!debt.pagado &&
                          porcentaje > 0 &&
                          porcentaje < 100) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: porcentaje / 100,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentColor,
                            ),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${porcentaje.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white30,
                              ),
                            ),
                            if (debt.numeroCuotas != null)
                              Text(
                                'Cuota ${debt.cuotasPagadas ?? 0}/${debt.numeroCuotas}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white30,
                                ),
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),

                      // FILA INFERIOR: Solo información limpia (La "X" fue eliminada)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (debt.fechaVencimiento != null) ...[
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'dd MMM, yyyy',
                              ).format(debt.fechaVencimiento!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                debt.esDeuda
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: accentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getEstadoTexto(debt, estaVencido),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Descripción (opcional)
                      if (debt.descripcion != null &&
                          debt.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          debt.descripcion!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Alerta de vencido
                      if (estaVencido) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 12,
                              color: Colors.redAccent.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                debt.esDeuda
                                    ? 'Vencido desde ${DateFormat('dd MMM').format(debt.fechaVencimiento!)}'
                                    : 'Cobro vencido desde ${DateFormat('dd MMM').format(debt.fechaVencimiento!)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getEstadoTexto(Debt debt, bool estaVencido) {
    if (debt.pagado) return 'Completado';
    if (estaVencido) return 'Vencido';
    if (debt.montoRestante < debt.cantidad) return 'Parcial';
    return 'Pendiente';
  }
}
