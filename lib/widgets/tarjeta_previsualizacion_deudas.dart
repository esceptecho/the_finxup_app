import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/screens/debt_agenda_view.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class TarjetaPrevisualizacionDeudas extends ConsumerWidget {
  const TarjetaPrevisualizacionDeudas({super.key});

  void _abrirBottomSheetDeudas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Mantiene esto para que pueda expandirse a pantalla completa si es necesario
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Obtenemos los insets internos del sistema (el tamaño del teclado)
        final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            // Añadimos padding dinámico abajo para esquivar el teclado
            padding: EdgeInsets.only(bottom: keyboardSpace),
            // Aseguramos que si el contenido es alto, no cause overflow interno
            child: const SafeArea(child: DebtAgendaView()),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtListProvider);

    final deudasPendientes = debts.where((d) => !d.pagado).toList();

    return SizedBox(
      height: 140, // Altura fija para el ListView horizontal
      child: deudasPendientes.isEmpty
          ? Card(
              elevation: 0,
              color: AppThemeHSL.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              child: InkWell(
                onTap: () => _abrirBottomSheetDeudas(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppThemeHSL.accentGold.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppThemeHSL.textPrimary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Agenda de Deudas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '¡Estás al día! No hay pendientes',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
            itemExtent: 250,
              scrollDirection: Axis.horizontal,
              itemCount:
                  deudasPendientes.length + 1, // +1 para el card principal
              itemBuilder: (context, index) {
                // Primer elemento: Card principal con resumen
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Card(
                      elevation: 0,
                      color: AppThemeHSL.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: InkWell(
                        onTap: () => _abrirBottomSheetDeudas(context),
                        borderRadius: BorderRadius.circular(7),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppThemeHSL.accentGold.withValues(
                                        alpha: 0.7,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: AppThemeHSL.textPrimary,
                                      size: 26,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${deudasPendientes.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Agenda de\nDeudas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                  ),
                                  // const SizedBox(height: 4),
                                  // Text(
                                  //   '${deudasPendientes.length} pendientes',
                                  //   style: TextStyle(
                                  //     color: Colors.redAccent.shade100,
                                  //     fontSize: 11,
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white54,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Siguientes elementos: Cards individuales de deudas
                final deuda = deudasPendientes[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Card(
                    elevation: 0,
                    color: AppThemeHSL.surfaceLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Aquí puedes navegar al detalle de la deuda
                        // o abrir el bottom sheet con esa deuda específica
                        _abrirBottomSheetDeudas(context);
                      },
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        width: 160, // Ancho fijo para cada card de deuda
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  deuda.esDeuda
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: deuda.esDeuda
                                      ? Colors.redAccent.shade100
                                      : Colors.greenAccent.shade100,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    deuda.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${deuda.cantidad.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: deuda.esDeuda
                                    ? Colors.redAccent.shade100
                                    : Colors.greenAccent.shade100,
                              ),
                            ),
                            const Spacer(),
                            if (deuda.fechaVencimiento != null)
                              Text(
                                'Vence: ${_formatDate(deuda.fechaVencimiento!)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            if (deuda.categoria != null &&
                                deuda.categoria!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  deuda.categoria!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Método auxiliar para formatear fechas (agrégalo a tu clase)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
