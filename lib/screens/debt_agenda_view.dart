import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/debt_model.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/providers/debts_filter_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/build_summary_item.dart';
import 'package:the_finxup_app/widgets/build_ui_debt_overlay.dart';
import 'package:the_finxup_app/widgets/debt_card_item.dart';
import 'package:the_finxup_app/widgets/debt_consumer_list_table_dialog.dart';

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
  CurrencyType _monedaSeleccionada = CurrencyType.usd;
  DateTime _fechaSeleccionada = DateTime.now();

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

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
      currencyType: _monedaSeleccionada,
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

  @override
  Widget build(BuildContext context) {
    // Si es mayor a 0, significa que el teclado está abierto
    final bool isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    // 1. Obtenemos todas las deudas y el texto de búsqueda actual
    // final debts = ref.watch(debtListProvider);
    final totalDeudas = ref.watch(totalDeudasProvider);
    final totalPrestamos = ref.watch(totalPrestamosProvider);

    // provider de busqueda

    // 2. Filtramos las deudas instantáneamente. Si está vacío, muestra todas.
    final filteredDebts = ref.watch(filteredDebtsProvider);

    // 1. Calculamos el 90% del ancho de la pantalla actual
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double anchoDeseado = anchoPantalla * 1.0;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppThemeHSL.background,
        cardColor: AppThemeHSL.surfaceLight,
      ),
      child: Scaffold(
        backgroundColor: AppThemeHSL.background,
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth:
              anchoDeseado, // 👈 Ampliamos el ancho para que quepan ambos widgets
          toolbarHeight: 55,
          leading: Builder(
            builder: (context) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Si puede regresar, añade el botón de atrás
                  if (Navigator.canPop(context)) const BackButton(),

                  // Tu elemento personalizado (ej. un pequeño logo)
                  const BuildUiDebtOverlay(),
                  SizedBox(height: 14),
                ],
              );
            },
          ),
          backgroundColor: AppThemeHSL.background,
          // title: const Text('Pantalla Secundaria'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.03,
                  ), // Un fondo sutil para dar contexto de tarjeta
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment
                      .end, // Alinea el botón al extremo derecho
                  children: [
                    // Sección de saldos (Por Pagar / Por Cobrar)
                    Row(
                      children: [
                        Expanded(
                          child: BuildSummaryItem(
                            title: 'Por Pagar',
                            amount: totalDeudas,
                            color: Colors.redAccent,
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.white12,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Expanded(
                          child: BuildSummaryItem(
                            title: 'Por Cobrar',
                            amount: totalPrestamos,
                            color: Colors.greenAccent,
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14), // Espaciador controlado
                    // Botón extendido elegante
                    TextButton.icon(
                      onPressed: () => _showDebtsTableDialog(context),
                      icon: Icon(
                        Icons.analytics_outlined,
                        color: AppThemeHSL.textSecondary,
                        size: 18,
                      ),
                      label: Text(
                        'Tabla de D&P',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppThemeHSL.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Un fondo casi invisible que reacciona al pasar el cursor o presionar
                        backgroundColor: AppThemeHSL.textSecondary.withValues(
                          alpha: 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // 2. Encabezado de la lista
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
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
                      '${filteredDebts.length} registros',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Listado de deudas (SE QUITÓ EL EXPANDED)
              filteredDebts.isEmpty
                  ? SizedBox(
                      height:
                          400, // Le damos una altura fija estimada a la vista vacía
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 120,
                              color: Colors.white10,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay préstamos para mostrar',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shrinkWrap: true, // Esto es vital aquí
                      physics:
                          const NeverScrollableScrollPhysics(), // Esto también
                      itemCount: filteredDebts.length,
                      itemBuilder: (context, index) {
                        final debt = filteredDebts[index];

                        return DebtCardItem(
                          debt: debt,
                          onCheckChanged: () {
                            ref
                                .read(debtListProvider.notifier)
                                .togglePagado(index);
                          },
                          onDelete: () {
                            ref
                                .read(debtListProvider.notifier)
                                .deleteDebt(index);
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
        // Botón flotante estilizado para invocar las acciones
        floatingActionButton: !isKeyboardOpen
            ? FloatingActionButton.extended(
                onPressed: () => _mostrarFormulario(context),
                backgroundColor: AppThemeHSL.accentGold,
                foregroundColor: Colors.black87,
                elevation: 4,
                icon: const Icon(
                  Icons.add_rounded,
                  fontWeight: FontWeight.bold,
                ),
                label: const Text(
                  'Agregar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }

  // 🏛️ DISEÑO: Diálogo optimizado al 90% con Tabla Compacta de Deudas
  void _showDebtsTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return DebtConsumerListTableDialog(dateFormat: dateFormat);
      },
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
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
            child: SingleChildScrollView(
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
                    'Nueo Préstamo',
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
                        size: 32,
                      ),
                      filled: true,
                      fillColor: AppThemeHSL.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLength: 60,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    maxLength: 9,
                    controller: _cantidadController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: AppThemeHSL.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),

                      // --- AQUÍ ESTÁ EL TRUCO ---
                      prefixIcon: Container(
                        width:
                            105, // Controla estrictamente el ancho del selector
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<CurrencyType>(
                                  value: _monedaSeleccionada,
                                  dropdownColor: AppThemeHSL.surface,
                                  menuWidth: 80,
                                  icon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppThemeHSL.accentGold,
                                    size: 28,
                                  ),
                                  isDense:
                                      true, // Hace que el diseño sea más compacto internamente
                                  items: CurrencyType.values.map((moneda) {
                                    return DropdownMenuItem(
                                      value: moneda,
                                      // Usamos el código (USD, EUR) para que no sature el espacio
                                      child: Text(
                                        moneda.code,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppThemeHSL.accentGold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (CurrencyType? newValue) {
                                    if (newValue != null) {
                                      // Actualiza el estado del modal usando setModalState
                                      setModalState(() {
                                        _monedaSeleccionada = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Línea divisoria vertical súper elegante
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.white12,
                              margin: const EdgeInsets.only(left: 4, right: 12),
                            ),
                          ],
                        ),
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
                            DateFormat(
                              'dd MMM, yyyy',
                            ).format(_fechaSeleccionada),
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
                          selectedColor: Colors.redAccent.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: Colors.redAccent,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: _esDeuda ? Colors.redAccent : Colors.white60,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) =>
                              setModalState(() => _esDeuda = true),
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
      ),
    );
  }
}
