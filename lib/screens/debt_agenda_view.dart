import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';

class DebtAgendaView extends ConsumerStatefulWidget {
  const DebtAgendaView({super.key});

  @override
  ConsumerState createState() => _DebtAgendaViewState();
}

class _DebtAgendaViewState extends ConsumerState<DebtAgendaView> {
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
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _cantidadController.clear();
    setState(() {
      _esDeuda = true;
      _fechaSeleccionada = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtListProvider);
    final notifier = ref.read(debtListProvider.notifier);

    // Colores del tema oscuro moderno
    const scaffoldBg = Color(0xFF121824);
    const cardBg = Color(0xFF1C2434);
    const accentBlue = Color(0xFF2F80ED);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: scaffoldBg,
        cardColor: cardBg,
      ),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: const Text('Agenda de Deudas', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: scaffoldBg,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Panel de Resumen Moderno
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Debo', notifier.totalDeudas, Colors.redAccent, Icons.arrow_upward),
                  Container(width: 1, height: 50, color: Colors.white10),
                  _buildSummaryItem('Me deben', notifier.totalPrestamos, Colors.greenAccent, Icons.arrow_downward),
                ],
              ),
            ),

            // Formulario Colapsable o Compacto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Concepto / Nombre',
                          prefixIcon: const Icon(Icons.person_outline, color: accentBlue),
                          filled: true,
                          fillColor: scaffoldBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _cantidadController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad (\$)',
                          prefixIcon: const Icon(Icons.monetization_on_outlined, color: accentBlue),
                          filled: true,
                          fillColor: scaffoldBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                if (date != null) setState(() => _fechaSeleccionada = date);
                              },
                              icon: const Icon(Icons.calendar_month, size: 18),
                              label: Text(DateFormat('dd MMM, yyyy').format(_fechaSeleccionada)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Colors.white10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Debo'),
                              selected: _esDeuda,
                              selectedColor: Colors.redAccent.withValues(alpha: 0.25),
                              checkmarkColor: Colors.redAccent,
                              labelStyle: TextStyle(color: _esDeuda ? Colors.redAccent : Colors.white60),
                              onSelected: (_) => setState(() => _esDeuda = true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Me deben'),
                              selected: !_esDeuda,
                              selectedColor: Colors.greenAccent.withValues(alpha: 0.25),
                              checkmarkColor: Colors.greenAccent,
                              labelStyle: TextStyle(color: !_esDeuda ? Colors.greenAccent : Colors.white60),
                              onSelected: (_) => setState(() => _esDeuda = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _guardarDeuda,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Registrar Transacción', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lista de deudas reactiva desde Hive
            Expanded(
              child: debts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.white24),
                          const SizedBox(height: 12),
                          const Text('Historial limpio por aquí', style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: debts.length,
                      itemBuilder: (context, index) {
                        final debt = debts[index];
                        final colorElement = debt.esDeuda ? Colors.redAccent : Colors.greenAccent;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: colorElement.withValues(alpha: 0.15),
                              child: Icon(debt.esDeuda ? Icons.arrow_upward : Icons.arrow_downward, color: colorElement, size: 20),
                            ),
                            title: Text(
                              debt.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: debt.pagado ? TextDecoration.lineThrough : null,
                                color: debt.pagado ? Colors.white38 : Colors.white,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${DateFormat('dd/MM/yyyy').format(debt.fecha)} • ${debt.tipoTransaccion}',
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${debt.cantidad.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: debt.pagado ? Colors.white38 : colorElement,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Checkbox(
                                  value: debt.pagado,
                                  activeColor: Colors.greenAccent,
                                  checkColor: scaffoldBg,
                                  onChanged: (_) => ref.read(debtListProvider.notifier).togglePagado(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.white38),
                                  onPressed: () => ref.read(debtListProvider.notifier).deleteDebt(index),
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
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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