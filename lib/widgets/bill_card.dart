import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
// Opcional para formatear fechas
import '../models/bill.dart';



class BillCard extends StatelessWidget {
  final Bill bill;
  final bool isPaid;

  const BillCard({super.key, required this.bill, required this.isPaid});

  void _crearRecordatorioCalendario(
    String titulo,
    double monto,
    DateTime fecha,
  ) {
    final Event event = Event(
      title: '🔴 Pagar: $titulo',
      description:
          'Recordatorio generado desde FINXUP.\nMonto a pagar: \$${monto.toStringAsFixed(2)}',
      location: 'App FINXUP',
      startDate: fecha,
      endDate: fecha,
      allDay: true, // Marca el evento para todo el día
      iosParams: const IOSParams(
        reminder: Duration(hours: 24), // Recuerda 1 día antes en iOS
      ),
      androidParams: const AndroidParams(
        emailInvites: [], // Requerido por la API aunque esté vacío
      ),
    );

    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeHSL.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bill.isPaid!
              ? AppThemeHSL.income.withValues(alpha: 0.3)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _crearRecordatorioCalendario(
              bill.title,
              bill.amount,
              bill.dueDate,
            ),
            child: CircleAvatar(
              backgroundColor: bill.isPaid!
                  ? AppThemeHSL.income
                  : AppThemeHSL.accentGold.withValues(alpha: 0.2),
              child: Icon(
                bill.isPaid! ? Icons.check : Icons.receipt_long,
                color: bill.isPaid! ? Colors.white : AppThemeHSL.accentGoldBright,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.title,
                  style: TextStyle(
                    color: AppThemeHSL.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Vence: ${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .end,
              children: [
                Text(
                  '\$${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppThemeHSL.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
