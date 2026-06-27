import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/currency_type_extensions.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/providers/financial_summary_provider.dart';
import 'package:the_finxup_app/screens/debt_detail_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DebtCardItem extends ConsumerWidget {
  final Debt debt;
  final VoidCallback onCheckChanged;
  final VoidCallback onDelete;

  const DebtCardItem({
    super.key,
    required this.debt,
    required this.onCheckChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorElement = debt.esDeuda ? Colors.redAccent : Colors.greenAccent;
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeHSL.surface,
            AppThemeHSL.surface.withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(
          color: estaVencido
              ? Colors.redAccent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          width: estaVencido ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DebtDetailScreen(
                  debt: debt,
                  onUpdate: (updatedDebt) {
                    // Actualizar en el notifier/repositorio
                  },
                  onDelete: () async {
                    // Eliminar del notifier/repositorio
                    // ref.read(debtListProvider.notifier).deleteDebt(index);
                    await ref.read(debtListProvider.notifier).deleteDebt(debt.id);
                  },
                ),
              ),
            );
          },//onDelete,
          splashColor: colorElement.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FILA SUPERIOR: Nombre, Monto Total y Checkbox
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
                              height: 1.3,
                              letterSpacing: -0.3,
                              decoration: debt.pagado
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: debt.pagado
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.white,
                            ),
                          ),
                          if (debt.categoria != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorElement.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                debt.categoria!,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: colorElement.withValues(alpha: 0.7),
                                ),
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
                                ? Colors.white.withValues(alpha: 0.3)
                                : colorElement,
                          ),
                        ),
                        if (debt.montoRestante != debt.cantidad &&
                            !debt.pagado) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Faltan: ${debt.currencyType.symbol}$pendienteFormateada',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 12),
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: debt.pagado,
                        activeColor: Colors.greenAccent,
                        checkColor: AppThemeHSL.background,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: const BorderSide(
                          color: Colors.white24,
                          width: 1.5,
                        ),
                        onChanged: (_) => onCheckChanged(),
                      ),
                    ),
                  ],
                ),

                // BARRA DE PROGRESO (si hay pago parcial)
                if (!debt.pagado && porcentaje > 0 && porcentaje < 100) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: porcentaje / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(colorElement),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${porcentaje.toStringAsFixed(0)}% completado',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                      if (debt.numeroCuotas != null)
                        Text(
                          'Cuota ${debt.cuotasPagadas ?? 0}/${debt.numeroCuotas}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white38,
                          ),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // FILA INFERIOR: Información detallada
                Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // runSpacing: 8,
                  // alignment: WrapAlignment.spaceBetween,
                  children: [
                    // Icono de dirección (Debo/Me deben)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorElement.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            debt.esDeuda
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: colorElement,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          debt.tipoTransaccion,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colorElement.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),

                    // Fecha de registro o acuerdo
                    if (debt.fechaVencimiento != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd MMM, yyyy',
                            ).format(debt.fechaVencimiento!),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Estado (con indicador visual)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(
                          debt,
                          estaVencido,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getEstadoColor(
                            debt,
                            estaVencido,
                          ).withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getEstadoIcon(debt, estaVencido),
                            size: 12,
                            color: _getEstadoColor(debt, estaVencido),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getEstadoTexto(debt, estaVencido),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getEstadoColor(debt, estaVencido),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón Eliminar
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),

                // Información adicional (si existe)
                if (debt.descripcion != null &&
                    debt.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            debt.descripcion!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Alerta de vencimiento
                if (estaVencido) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.redAccent.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            debt.esDeuda
                                ? 'Pago vencido desde ${DateFormat('dd MMM').format(debt.fechaVencimiento!)}'
                                : 'Cobro vencido desde ${DateFormat('dd MMM').format(debt.fechaVencimiento!)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.redAccent.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(Debt debt, bool estaVencido) {
    if (debt.pagado) return Colors.greenAccent;
    if (estaVencido) return Colors.redAccent;
    if (debt.montoRestante < debt.cantidad) return Colors.blueAccent;
    return Colors.orangeAccent;
  }

  IconData _getEstadoIcon(Debt debt, bool estaVencido) {
    if (debt.pagado) return Icons.check_circle_rounded;
    if (estaVencido) return Icons.warning_rounded;
    if (debt.montoRestante < debt.cantidad) {
      return Icons.hourglass_empty_rounded;
    }
    return Icons.pending_rounded;
  }

  String _getEstadoTexto(Debt debt, bool estaVencido) {
    if (debt.pagado) return 'Completado';
    if (estaVencido) return 'Vencido';
    if (debt.montoRestante < debt.cantidad) return 'En proceso';
    return 'Pendiente';
  }
}
