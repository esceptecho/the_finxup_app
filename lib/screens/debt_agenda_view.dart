import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DebtAgendaView extends ConsumerStatefulWidget {
  const DebtAgendaView({super.key});

  @override
  ConsumerState createState() => _DebtAgendaViewState();
}

class _DebtAgendaViewState extends ConsumerState<DebtAgendaView> {
  // Los controladores se mantienen aquí para pasarlos al BottomSheet
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  bool _esDeuda = true;
  DateTime _fechaSeleccionada = DateTime.now();

  void _guardarDeuda() {
    if (_nombreController.text.isEmpty || _cantidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nuevaDeuda = Debt(
      nombre: _nombreController.text,
      cantidad: double.parse(_cantidadController.text),
      fecha: _fechaSeleccionada,
      esDeuda: _esDeuda,
    );

    ref.read(debtListProvider.notifier).addDebt(nuevaDeuda);
    _limpiarCampos();
    Navigator.pop(context); // Cierra el BottomSheet tras guardar
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _cantidadController.clear();
    setState(() {
      _esDeuda = true;
      _fechaSeleccionada = DateTime.now();
    });
  }

  // Muestra el formulario de registro con un estilo sofisticado
  void _mostrarFormulario(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeHSL.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nueva Transacción',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Concepto / Nombre',
                    labelStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: Icon(
                      Icons.abc_rounded,
                      color: AppThemeHSL.accentGold,
                    ),
                    filled: true,
                    fillColor:
                        AppThemeHSL.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _cantidadController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: Icon(
                      Icons.attach_money_rounded,
                      color: AppThemeHSL.accentGold,
                    ),
                    filled: true,
                    fillColor:
                        AppThemeHSL.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fechaSeleccionada,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _fechaSeleccionada = date);
                            setModalState(() {});
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                        ),
                        label: Text(
                          DateFormat('dd MMM, yyyy').format(_fechaSeleccionada),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Debo')),
                        selected: _esDeuda,
                        selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                        checkmarkColor: Colors.redAccent,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: _esDeuda ? Colors.redAccent : Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setModalState(() => _esDeuda = true),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _esDeuda
                                ? Colors.redAccent.withValues(alpha: 0.5)
                                : Colors.white12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Me deben')),
                        selected: !_esDeuda,
                        selectedColor: Colors.greenAccent.withValues(
                          alpha: 0.2,
                        ),
                        checkmarkColor: Colors.greenAccent,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: !_esDeuda
                              ? Colors.greenAccent
                              : Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) =>
                            setModalState(() => _esDeuda = false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: !_esDeuda
                                ? Colors.greenAccent.withValues(alpha: 0.5)
                                : Colors.white12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardarDeuda,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeHSL.accentGold,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Registro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtListProvider);
    final totalDeudas = ref.watch(totalDeudasProvider);
    final totalPrestamos = ref.watch(totalPrestamosProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppThemeHSL.background,
        cardColor: AppThemeHSL.surfaceLight,
      ),
      child: Scaffold(
        backgroundColor: AppThemeHSL.background,
        appBar: AppBar(
          title: const Text(
            'Préstamos y Deudas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 24,
            ),
          ),
          backgroundColor: AppThemeHSL.background,
          elevation: 0,
          centerTitle: false,
        ),
        body: Column(
          children: [
            // Resumen de balances financieros estilo Tarjeta Premium
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: AppThemeHSL.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Por Pagar',
                      totalDeudas,
                      Colors.redAccent,
                      Icons.arrow_upward_rounded,
                    ),
                  ),
                  Container(width: 1, height: 45, color: Colors.white12),
                  Expanded(
                    child: _buildSummaryItem(
                      'Por Cobrar',
                      totalPrestamos,
                      Colors.greenAccent,
                      Icons.arrow_downward_rounded,
                    ),
                  ),
                ],
              ),
            ),

            // Encabezado de la lista
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Historial de Actividad',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${debts.length} registros',
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Listado de deudas optimizado
            Expanded(
              child: debts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 56,
                            color: Colors.white10,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay transacciones pendientes',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: debts.length,
                      itemBuilder: (context, index) {
                        final debt = debts[index];
                        final colorElement = debt.esDeuda
                            ? Colors.redAccent
                            : Colors.greenAccent;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppThemeHSL.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.03),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorElement.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                debt.esDeuda
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: colorElement,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              debt.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: debt.pagado
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: debt.pagado
                                    ? Colors.white38
                                    : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMM, yyyy').format(debt.fecha),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${debt.cantidad.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: debt.pagado
                                            ? Colors.white38
                                            : colorElement,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      debt.pagado ? 'Pagado' : 'Pendiente',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: debt.pagado
                                            ? Colors.white24
                                            : colorElement.withValues(
                                                alpha: 0.6,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: debt.pagado,
                                    activeColor: Colors.greenAccent,
                                    checkColor: AppThemeHSL.background,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (_) => ref
                                        .read(debtListProvider.notifier)
                                        .togglePagado(index),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: Colors.white30,
                                  ),
                                  onPressed: () => ref
                                      .read(debtListProvider.notifier)
                                      .deleteDebt(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        // Botón flotante estilizado para invocar las acciones
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrarFormulario(context),
          backgroundColor: AppThemeHSL.accentGold,
          foregroundColor: Colors.black87,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, fontWeight: FontWeight.bold),
          label: const Text(
            'Agregar',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 12),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }
}
