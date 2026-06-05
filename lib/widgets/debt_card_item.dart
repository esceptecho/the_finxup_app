import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/new_financial_summary_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DebtCardItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorElement = debt.esDeuda ? Colors.redAccent : Colors.greenAccent;
    final debtCantidad = CurrencyFormatter.formatDebt(debt.cantidad);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppThemeHSL.surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FILA SÚPERIOR: Nombre (Expandido), Cantidad y Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Alinea arriba por si el título usa 2 líneas
            children: [
              Expanded(
                child: Text(
                  debt.nombre,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.2,
                    letterSpacing: -0.2,
                    decoration: debt.pagado ? TextDecoration.lineThrough : null,
                    color: debt.pagado ? Colors.white38 : Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${debt.currencyType.symbol}$debtCantidad ${debt.currencyType.name}',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: debt.pagado ? Colors.white38 : colorElement,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: debt.pagado,
                  activeColor: Colors.greenAccent,
                  checkColor: AppThemeHSL.background,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: const BorderSide(color: Colors.white24, width: 1.5),
                  onChanged: (_) => onCheckChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // const SizedBox(height: 4),
          // Separación entre la fila superior e inferior
          // FILA INFERIOR: Icono de tipo, Fecha, Estado (Pagado/Pendiente) y Botón Eliminar
          Row(
            children: [
              // Icono de Estado (Deuda/Crédito)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorElement.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  debt.esDeuda
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: colorElement,
                  size: 13,
                ),
              ),
              // Fecha
              Text(
                DateFormat('dd MMM, yyyy').format(debt.fecha),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(), // Empuja el estado y el botón eliminar hacia la derecha
              // Estado (Pagado / Pendiente)
              Text(
                debt.pagado ? 'Pagado' : 'Pendiente',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: debt.pagado
                      ? Colors.white24
                      : Colors.white38,
                ),
              ),
              const SizedBox(width: 8),

              // Botón Eliminar (Icons.close_rounded)
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.white30,
                  ),
                  splashRadius: 20,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


