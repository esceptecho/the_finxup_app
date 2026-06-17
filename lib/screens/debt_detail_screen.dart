import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/providers/new_financial_summary_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final Debt debt;
  final Function(Debt) onUpdate;
  final VoidCallback onDelete;

  const DebtDetailScreen({
    super.key,
    required this.debt,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen> {
  late Debt _debt;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controladores para edición
  late TextEditingController _nombreController;
  late TextEditingController _cantidadController;
  late TextEditingController _descripcionController;
  late TextEditingController _entidadController;
  late TextEditingController _tasaInteresController;
  late TextEditingController _numeroCuotasController;
  late DateTime _fechaSeleccionada;
  late DateTime? _fechaVencimientoSeleccionada;
  late CurrencyType _currencyTypeSeleccionado;
  late bool _esDeudaSeleccionado;

  @override
  void initState() {
    super.initState();
    _debt = widget.debt;
    _inicializarControladores();
  }

  void _inicializarControladores() {
    _nombreController = TextEditingController(text: _debt.nombre);
    _cantidadController = TextEditingController(
      text: _debt.cantidad.toString(),
    );
    _descripcionController = TextEditingController(
      text: _debt.descripcion ?? '',
    );
    _entidadController = TextEditingController(text: _debt.entidad ?? '');
    _tasaInteresController = TextEditingController(
      text: _debt.tasaInteres?.toString() ?? '',
    );
    _numeroCuotasController = TextEditingController(
      text: _debt.numeroCuotas?.toString() ?? '',
    );
    _fechaSeleccionada = _debt.fecha;
    _fechaVencimientoSeleccionada = _debt.fechaVencimiento;
    _currencyTypeSeleccionado = _debt.currencyType;
    _esDeudaSeleccionado = _debt.esDeuda;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _descripcionController.dispose();
    _entidadController.dispose();
    _tasaInteresController.dispose();
    _numeroCuotasController.dispose();
    super.dispose();
  }

  Future<void> _agregarPago() async {
    final montoPago = await _showMontoDialog();
    if (montoPago != null && montoPago > 0) {
      final nuevoPago = DebtPayment(
        fecha: DateTime.now(),
        monto: montoPago,
        nota: await _showNotaDialog(),
      );

      setState(() {
        final pagosActualizados = List<DebtPayment>.from(
          _debt.pagosRealizados ?? [],
        );
        pagosActualizados.add(nuevoPago);

        final nuevoMontoPagado = (_debt.montoPagado ?? 0) + montoPago;
        final nuevoPagado = nuevoMontoPagado >= _debt.cantidad;

        _debt = _debt.copyWith(
          pagosRealizados: pagosActualizados,
          montoPagado: nuevoMontoPagado,
          pagado: nuevoPagado,
        );

        if (_debt.numeroCuotas != null && _debt.numeroCuotas! > 0) {
          final cuotasActualizadas = (_debt.cuotasPagadas ?? 0) + 1;
          _debt = _debt.copyWith(cuotasPagadas: cuotasActualizadas);
        }
      });

      ref.read(debtListProvider.notifier).updateDebt(_debt);
    }
  }

  Future<double?> _showMontoDialog() async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar ${_debt.esDeuda ? 'pago' : 'cobro'}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Monto',
            prefixText: '${_debt.currencyType.symbol} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(controller.text);
              if (monto != null && monto > 0) {
                Navigator.pop(context, monto);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showNotaDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nota (opcional)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Descripción del pago'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Omitir'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarPago(int index) {
    setState(() {
      final pagosActualizados = List<DebtPayment>.from(_debt.pagosRealizados!);
      final pagoEliminado = pagosActualizados.removeAt(index);

      final nuevoMontoPagado = (_debt.montoPagado ?? 0) - pagoEliminado.monto;
      final nuevoPagado = nuevoMontoPagado >= _debt.cantidad;

      _debt = _debt.copyWith(
        pagosRealizados: pagosActualizados.isEmpty ? null : pagosActualizados,
        montoPagado: nuevoMontoPagado,
        pagado: nuevoPagado,
      );

      if (_debt.numeroCuotas != null && _debt.numeroCuotas! > 0) {
        final cuotasActualizadas = (_debt.cuotasPagadas ?? 0) - 1;
        _debt = _debt.copyWith(cuotasPagadas: cuotasActualizadas);
      }
    });
    ref.read(debtListProvider.notifier).updateDebt(_debt);
  }

  void _guardarEdicion() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _debt = _debt.copyWith(
          nombre: _nombreController.text,
          cantidad: double.parse(_cantidadController.text),
          descripcion: _descripcionController.text.isEmpty
              ? null
              : _descripcionController.text,
          entidad: _entidadController.text.isEmpty
              ? null
              : _entidadController.text,
          tasaInteres: _tasaInteresController.text.isEmpty
              ? null
              : double.parse(_tasaInteresController.text),
          numeroCuotas: _numeroCuotasController.text.isEmpty
              ? null
              : int.parse(_numeroCuotasController.text),
          fecha: _fechaSeleccionada,
          fechaVencimiento: _fechaVencimientoSeleccionada,
          currencyType: _currencyTypeSeleccionado,
          esDeuda: _esDeudaSeleccionado,
        );
        _isEditing = false;
      });
      ref.read(debtListProvider.notifier).updateDebt(_debt);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observamos la lista global de Riverpod
    final debts = ref.watch(debtListProvider);

    // Buscamos la versión más actualizada de ESTA deuda en específico
    // Si no se encuentra (ej. porque la acabas de eliminar), conservamos la que ya estaba cargada
    _debt = debts.firstWhere(
      (d) => d.id == widget.debt.id,
      orElse: () => _debt,
    );

    final colorElement = _debt.esDeuda ? Colors.redAccent : Colors.greenAccent;
    final porcentaje = _debt.porcentajePagado;
    final restante = _debt.montoRestante;
    final estaVencida = _debt.isOverdue;

    return Scaffold(
      backgroundColor: AppThemeHSL.background,
      appBar: AppBar(
        backgroundColor: AppThemeHSL.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Editar Deuda' : _debt.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _guardarEdicion,
              child: const Text('Guardar'),
            ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: () {
              _showDeleteDialog();
            },
          ),
        ],
      ),
      body: _isEditing
          ? _buildEditForm()
          : _buildDetailView(colorElement, porcentaje, restante, estaVencida),
    );
  }

  Widget _buildDetailView(
    Color colorElement,
    double porcentaje,
    double restante,
    bool estaVencida,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con información principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorElement.withValues(alpha: 0.15),
                  AppThemeHSL.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                // Tipo de transacción
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorElement.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _debt.esDeuda
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 16,
                        color: colorElement,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _debt.tipoTransaccion,
                        style: TextStyle(
                          color: colorElement,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Monto total
                Text(
                  '${_debt.currencyType.symbol}${CurrencyFormatter.formatDebt(_debt.cantidad)}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _debt.pagado ? Colors.white38 : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(estaVencida).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _debt.estadoDeuda,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getEstadoColor(estaVencida),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de progreso
          if (!_debt.pagado && porcentaje > 0)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso de pago',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${porcentaje.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorElement,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: porcentaje / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(colorElement),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pagado: ${_debt.currencyType.symbol}${CurrencyFormatter.formatDebt(_debt.montoPagado ?? 0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                      Text(
                        'Restante: ${_debt.currencyType.symbol}${CurrencyFormatter.formatDebt(restante)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Información detallada
          _buildInfoSection(),

          // Pagos realizados
          _buildPaymentsSection(colorElement),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeHSL.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Información detallada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

          _infoTile(
            icon: Icons.person_rounded,
            label: 'Entidad',
            value: _debt.entidad ?? 'No especificada',
          ),
          _infoTile(
            icon: Icons.description_rounded,
            label: 'Descripción',
            value: _debt.descripcion ?? 'Sin descripción',
          ),
          _infoTile(
            icon: Icons.calendar_today_rounded,
            label: 'Fecha de registro',
            value: DateFormat('dd MMMM, yyyy').format(_debt.fecha),
          ),
          if (_debt.fechaVencimiento != null)
            _infoTile(
              icon: Icons.event_busy_rounded,
              label: 'Fecha de vencimiento',
              value: DateFormat(
                'dd MMMM, yyyy',
              ).format(_debt.fechaVencimiento!),
              valueColor: _debt.isOverdue ? Colors.redAccent : null,
            ),
          if (_debt.tasaInteres != null)
            _infoTile(
              icon: Icons.trending_up_rounded,
              label: 'Tasa de interés',
              value: '${_debt.tasaInteres}% anual',
            ),
          if (_debt.numeroCuotas != null)
            _infoTile(
              icon: Icons.receipt_rounded,
              label: 'Plazo',
              value:
                  '${_debt.cuotasPagadas ?? 0}/${_debt.numeroCuotas} cuotas pagadas',
            ),
          if (_debt.recurrenceType != null)
            _infoTile(
              icon: Icons.repeat_rounded,
              label: 'Recurrencia',
              value: _getRecurrenceText(_debt.recurrenceType!),
            ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection(Color colorElement) {
    if (_debt.pagosRealizados == null || _debt.pagosRealizados!.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppThemeHSL.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.payment_rounded, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'Sin pagos registrados',
              style: TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _agregarPago,
              icon: const Icon(Icons.add_rounded),
              label: Text(_debt.esDeuda ? 'Registrar pago' : 'Registrar cobro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorElement,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeHSL.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial de pagos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _agregarPago,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(_debt.esDeuda ? 'Pago' : 'Cobro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorElement,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _debt.pagosRealizados!.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final pago = _debt.pagosRealizados![index];
              return Dismissible(
                key: Key(pago.fecha.toString()),
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Eliminar pago'),
                      content: const Text(
                        '¿Estás seguro de eliminar este registro?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) => _eliminarPago(index),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorElement.withValues(alpha: 0.15),
                    child: Icon(
                      _debt.esDeuda
                          ? Icons.payment_rounded
                          : Icons.attach_money_rounded,
                      color: colorElement,
                    ),
                  ),
                  title: Text(
                    '${_debt.currencyType.symbol}${CurrencyFormatter.formatDebt(pago.monto)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    pago.nota ?? 'Sin nota',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    DateFormat('dd MMM, yyyy HH:mm').format(pago.fecha),
                    style: const TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.label_rounded),
              ),
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cantidadController,
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                prefixText: '${_debt.currencyType.symbol} ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _entidadController,
              decoration: const InputDecoration(
                labelText: 'Entidad',
                prefixIcon: Icon(Icons.business_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildDatePicker(
              label: 'Fecha de registro',
              fecha: _fechaSeleccionada,
              onChanged: (date) => setState(() => _fechaSeleccionada = date),
            ),
            const SizedBox(height: 12),
            _buildDatePicker(
              label: 'Fecha de vencimiento (opcional)',
              fecha: _fechaVencimientoSeleccionada,
              onChanged: (date) =>
                  setState(() => _fechaVencimientoSeleccionada = date),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tasaInteresController,
              decoration: const InputDecoration(
                labelText: 'Tasa de interés anual (%)',
                prefixIcon: Icon(Icons.percent_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numeroCuotasController,
              decoration: const InputDecoration(
                labelText: 'Número de cuotas (opcional)',
                prefixIcon: Icon(Icons.receipt_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CurrencyType>(
              initialValue: _currencyTypeSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Moneda',
                prefixIcon: Icon(Icons.currency_exchange_rounded),
              ),
              items: CurrencyType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text('${type.symbol} - ${type.name.toUpperCase()}'),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _currencyTypeSeleccionado = value!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Es deuda (Debo)'),
              subtitle: Text(
                _esDeudaSeleccionado ? 'Debes pagar' : 'Te deben pagar',
              ),
              value: _esDeudaSeleccionado,
              onChanged: (value) =>
                  setState(() => _esDeudaSeleccionado = value),
              secondary: Icon(
                _esDeudaSeleccionado
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: _esDeudaSeleccionado
                    ? Colors.redAccent
                    : Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? fecha,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: fecha ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(
          fecha != null
              ? DateFormat('dd MMMM, yyyy').format(fecha)
              : 'No especificada',
        ),
      ),
    );
  }

  Color _getEstadoColor(bool estaVencida) {
    if (_debt.pagado) return Colors.greenAccent;
    if (estaVencida) return Colors.redAccent;
    if (_debt.montoRestante < _debt.cantidad) return Colors.blueAccent;
    return Colors.orangeAccent;
  }

  String _getRecurrenceText(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.oneTime:
        return 'Única vez';
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.biweekly:
        return 'Quincenal';
      case RecurrenceType.monthly:
        return 'Mensual';
      case RecurrenceType.quarterly:
        return 'Trimestral';
      case RecurrenceType.yearly:
        return 'Anual';
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar deuda'),
        content: Text('¿Estás seguro de eliminar "${_debt.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(debtListProvider.notifier).deleteDebt(_debt.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
