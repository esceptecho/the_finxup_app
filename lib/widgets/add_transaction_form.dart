// ignore_for_file: deprecated_member_use

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/utils/string_extensions.dart';
import 'package:the_finxup_app/utils/transaction_utils.dart';
import 'package:the_finxup_app/widgets/new_custom_animation_dialog.dart';
import '../models/hive_transaction_model.dart'; // Tu nuevo modelo Hive
import '../models/bill.dart';

class AddTransactionForm extends ConsumerStatefulWidget {
  final Function(Transaction) onAdd;
  final Function(Bill) onAddBill;
  final Transaction? initialTransaction;
  final Bill? initialBill;
  final bool isBillMode;

  const AddTransactionForm({
    super.key,
    required this.onAdd,
    required this.onAddBill,
    this.initialTransaction,
    this.initialBill,
    required this.isBillMode,
  });

  @override
  ConsumerState<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends ConsumerState<AddTransactionForm> {
  late TextEditingController _descController;
  late TextEditingController _amountController;
  // 1. Creamos el controlador
  final ScrollController _scrollController = ScrollController();
  // 1. DECLARAR LA VARIABLE AQUÍ
  // Un FocusNode para cada TextField
  final FocusNode _descFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  // Variables para rastrear el estado visualmente
  bool _isEditingAmount = false;
  bool _isEditingDesc = false;

  // Actualizado al nuevo enum del modelo
  TransactionType _selectedType = TransactionType.expense;
  dynamic _selectedSubCategory = ExpenseSubCategory.food; // Valor inicial
  double _previewTotal = 0.0;
  bool _createCalendarReminder = true;
  DateTime _selectedDate = DateTime.now();
  String _selectedRecurrence = 'Única vez';
  double __calculatedRecurrence = 0.0;

  final List<String> _recurrenceOptions = [
    'Única vez',
    'Diario',
    'Semanal',
    'Mensual',
    'Trimestral',
    'Semestral',
    'Anual',
  ];

  void _updatePreview() {
    final double? amount = double.tryParse(_amountController.text);

    // Si el monto es nulo o vacío, ponemos 0
    if (amount == null) {
      setState(() => _previewTotal = 0.0);
      return;
    }

    // Llamas a tu lógica matemática (la que definimos antes)
    __calculatedRecurrence = TransactionUtilsTM.calculateHistoricalPreviewTM(
      amount: amount,
      startDate: _selectedDate,
      recurrence: _selectedRecurrence,
    );

    setState(() {
      _previewTotal = __calculatedRecurrence;
    });
  }

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(
      text: widget.initialTransaction?.description ?? "",
    );
    _amountController = TextEditingController(
      text: widget.initialTransaction?.amount.toString() ?? "",
    );

    if (widget.initialTransaction != null) {
      _selectedType = widget.initialTransaction!.type;
      _selectedDate = widget.initialTransaction!.date;
    }

    _amountController.addListener(_updatePreview);

    // Listener para Descripción
    _descFocusNode.addListener(() {
      // ✅ FILTRO: Solo actuar cuando gana el foco
      if (_descFocusNode.hasFocus) {
        setState(() => _isEditingDesc = true);
        // ✅ ESPERA: Dejamos que el teclado suba primero
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        setState(() => _isEditingDesc = false);
      }
    });

    // Listener para Monto
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        setState(() => _isEditingAmount = true);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
      } else {
        setState(() => _isEditingAmount = false);
      }
    });
  }

  void _scrollToBottom() {
    // ✅ SEGURIDAD: Verificar que el scroll esté montado
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 300,
        ), // Un poco más rápido se siente mejor
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    // Siempre limpia el listener para evitar fugas de memoria
    _amountController.removeListener(_updatePreview);
    _descFocusNode.dispose();
    _amountFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppThemeHSL.primary,
              onPrimary: Colors.white,
              surface: AppThemeHSL.surfaceMid,
              onSurface: AppThemeHSL.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _updatePreview(); // Actualizamos al cambiar fecha
      });
    }
    _updatePreview();
  }

  void _crearRecordatorioCalendario({
    required String titulo,
    required double monto,
    required DateTime fecha,
    String frecuencia = 'Única vez',
  }) {
    Recurrence? recurrence;
    if (frecuencia == 'Semanal') {
      recurrence = Recurrence(frequency: Frequency.weekly);
    } else if (frecuencia == 'Mensual') {
      recurrence = Recurrence(frequency: Frequency.monthly);
    }

    final Event event = Event(
      title: '🔴 Pagar: $titulo',
      description:
          'Monto: \$${monto.toStringAsFixed(2)}\nGenerado desde FINXUP',
      startDate: fecha,
      endDate: fecha.add(const Duration(hours: 1)),
      allDay: true,
      recurrence: recurrence,
    );

    Add2Calendar.addEvent2Cal(event);
  }

  void _updateTransactionType(TransactionType newType) {
    setState(() {
      _selectedType = newType;
      // Usamos la extensión .subCategories que creamos antes
      // Asegura que la subcategoría exista en el nuevo tipo
      _selectedSubCategory = newType.subCategories.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el espacio del teclado solo para el padding exterior si es necesario
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // QUITAMOS el viewInsets de aquí para que el scroll funcione bien
      padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppThemeHSL.surfaceMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        // Aplicamos el desplazamiento del teclado aquí, fuera del Scroll
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: SingleChildScrollView(
          controller: _scrollController,
          // IMPORTANTE: Esto ayuda a que el teclado responda al primer toque
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del BottomSheet
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  widget.isBillMode ? "Nueva Factura" : "Nueva Transacción",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppThemeHSL.textPrimary,
                  ),
                ),
                subtitle: Text(
                  widget.isBillMode
                      ? "Se guardará como pendiente"
                      : "Afectará tu balance actual",
                  style: TextStyle(
                    color: AppThemeHSL.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedRecurrence,
                  dropdownColor: AppThemeHSL.surfaceLight,
                  underline: const SizedBox(),
                  items: _recurrenceOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedRecurrence = val!;
                      _updatePreview();
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Campo Descripción
              if (_descController.text.isNotEmpty && _isEditingDesc)
                Text(
                  "💵 ¡Es bueno una descripción intencional!",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              _descTextField(context),

              const SizedBox(height: 8),

              // Campo Monto
              if (_amountController.text.isNotEmpty &&
                  _isEditingAmount) // _isEditingAmount
                Text(
                  "💵 ¡No olvides incluir los decimales!",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              _amountTextField(context),

              const SizedBox(height: 8),

              DropdownButtonFormField<dynamic>(
                key: ValueKey(
                  _selectedType, 
                ), // 🔑 Fuerza la reconstrucción completa
                //Ya que al usar ValueKey, el dropdown se reconstruye completamente con el nuevo _selectedSubCategory correcto.
                value: _selectedSubCategory,
                // _updateTransactionType ya establece _selectedSubCategory = newType.subCategories.first, 
                // no necesitas la validación extra.
                // _selectedType.subCategories.contains(_selectedSubCategory)
                // ? _selectedSubCategory
                // : _selectedType.subCategories.first,

                // SOLUCIÓN: Usamos el constructor de decoración normal
                // y aplicamos los estilos manualmente o mediante el tema del contexto
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  // Traemos los estilos del tema global uno por uno para asegurar compatibilidad
                  filled: true,
                  fillColor: AppThemeHSL.surfaceLighter.withValues(alpha: 0.3),
                  contentPadding: Theme.of(
                    context,
                  ).inputDecorationTheme.contentPadding,
                  enabledBorder: Theme.of(
                    context,
                  ).inputDecorationTheme.enabledBorder,
                  labelStyle: TextStyle(color: AppThemeHSL.textMuted),

                  // El borde dinámico que querías
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _selectedType == TransactionType.income
                          ? AppThemeHSL.incomeDark.withValues(alpha: 0.3)
                          : AppThemeHSL.expenseDark.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  border: InputBorder.none, // OutlineInputBorder(),
                ),

                items: _selectedType.subCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(
                          categoryIcons[cat] ?? Icons.help_outline,
                          color: _selectedType == TransactionType.income
                              ? AppThemeHSL.income
                              : AppThemeHSL.expense,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          cat.name.toUpperCase(),
                          style: TextStyle(color: AppThemeHSL.textPrimary),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _selectedSubCategory = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              if (!_isEditingDesc) _showPreviewAmount(),
              // Selector de Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.isBillMode ? "Vence" : "Fecha"}: ${DateFormat.yMMMd('es_ES').format(_selectedDate)}',
                    style: TextStyle(
                      color: AppThemeHSL.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(
                      Icons.calendar_today,
                      color: AppThemeHSL.textSecondary.withValues(alpha: 0.8),
                    ),
                    label: Text(
                      'Elegir Fecha',
                      style: TextStyle(
                        color: AppThemeHSL.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    onPressed: _presentDatePicker,
                  ),
                ],
              ),

              if (widget.isBillMode)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Recordatorio en calendario",
                    style: TextStyle(
                      color: AppThemeHSL.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  value: _createCalendarReminder,
                  activeColor: AppThemeHSL.income,
                  onChanged: (val) =>
                      setState(() => _createCalendarReminder = val),
                ),

              if (!widget.isBillMode) _choiceChips(),

              const SizedBox(height: 12),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    // Fondo blanco (o transparente si el fondo de la app ya es blanco)
                    backgroundColor: AppThemeHSL.surfaceLighter,
                    // El color del texto, el icono y el "overlay" (efecto al presionar)
                    foregroundColor: AppThemeHSL.textPrimary,
                    // Definimos el borde con el color primario
                    side: BorderSide(color: AppThemeHSL.divider, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    _updatePreview();
                    _handleSave();
                    final double? amount = double.tryParse(
                      _amountController.text,
                    );

                    if (_descController.text.isEmpty || amount == null) return;

                    // Primero guardamos la referencia al Navigator
                    final navigator = Navigator.of(context);

                    // 1. Cerramos la pantalla actual de inmediato
                    navigator.pop();

                    // 2. Mostramos el diálogo sobre la pantalla que quedó atrás
                    // Usamos el 'navigator.context' porque ese contexto SÍ sigue vivo
                    CustomDialogHelper.showAnimated(
                      navigator.context,
                      title: widget.isBillMode
                          ? 'Factura guardada: ${_descController.text}'
                          : 'Transacción guardada: ${_descController.text}',
                      lottiePath: 'assets/lotties/Done.json',
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Guardar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _choiceChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text("Gasto"),
            selected: _selectedType == TransactionType.expense,

            // --- COLORES DE FONDO ---
            // Color cuando está SELECCIONADO
            selectedColor: AppThemeHSL.primary,

            // Color cuando NO está seleccionado
            backgroundColor: AppThemeHSL.surfaceLighter.withValues(alpha: 0.5),

            // Color del texto/check según el estado
            labelStyle: TextStyle(
              color: _selectedType == TransactionType.expense
                  ? Colors.white
                  : AppThemeHSL.textPrimary,
              fontWeight: FontWeight.bold,
            ),

            // Color del símbolo de "check"
            checkmarkColor: Colors.white,

            // --- BORDES (Opcional) ---
            side: BorderSide(
              color: _selectedType == TransactionType.expense
                  ? AppThemeHSL.expenseDark
                  : AppThemeHSL.expenseLight.withValues(alpha: 0.1),
            ),

            onSelected: (val) =>
                val ? _updateTransactionType(TransactionType.expense) : null,
          ),
          const SizedBox(width: 20),
          ChoiceChip(
            label: const Text("Ingreso"),

            selected: _selectedType == TransactionType.income,

            // --- COLORES DE FONDO ---
            // Color cuando está SELECCIONADO
            selectedColor: AppThemeHSL.incomeDark,

            // Color cuando NO está seleccionado
            backgroundColor: AppThemeHSL.surfaceLighter.withValues(alpha: 0.5),

            // --- COLORES DE TEXTO E ICONOS ---
            // Color del texto/check según el estado
            labelStyle: TextStyle(
              color: _selectedType == TransactionType.income
                  ? Colors.white
                  : AppThemeHSL.textPrimary,
              fontWeight: FontWeight.bold,
            ),

            // Color del símbolo de "check"
            checkmarkColor: Colors.white,

            // --- BORDES (Opcional) ---
            side: BorderSide(
              color: _selectedType == TransactionType.income
                  ? AppThemeHSL.income
                  : AppThemeHSL.incomeLight.withValues(alpha: 0.1),
            ),
            onSelected: (val) =>
                val ? _updateTransactionType(TransactionType.income) : null,
          ),
        ],
      ),
    );
  }

  TextField _amountTextField(BuildContext context) {
    return TextField(
      controller: _amountController,
      focusNode: _amountFocusNode,
      cursorColor: AppThemeHSL.textSecondary,
      showCursor: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: AppThemeHSL.textPrimary),
      decoration: InputDecoration(
        labelText: 'Monto',
        filled: true,
        fillColor: AppThemeHSL.surfaceLighter.withValues(alpha: 0.3),
        contentPadding: Theme.of(context).inputDecorationTheme.contentPadding,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        labelStyle: TextStyle(color: AppThemeHSL.textMuted),

        // El borde dinámico que querías
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _selectedType == TransactionType.income
                ? AppThemeHSL.incomeDark.withValues(alpha: 0.3)
                : AppThemeHSL.expenseDark.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        border: InputBorder.none, // OutlineInputBorder(),
      ),
    );
  }

  TextField _descTextField(BuildContext context) {
    return TextField(
      controller: _descController,
      focusNode: _descFocusNode,
      cursorColor: AppThemeHSL.textSecondary,
      showCursor: true,
      style: TextStyle(color: AppThemeHSL.textPrimary),
      decoration: InputDecoration(
        labelText: !widget.isBillMode
            ? (_selectedType == TransactionType.income
                  ? 'Origen del ingreso'
                  : '¿En qué gastaste?')
            : (widget.isBillMode ? 'Factura por pagar' : null),
        filled: true,
        fillColor: AppThemeHSL.surfaceLighter.withValues(alpha: 0.3),
        contentPadding: Theme.of(context).inputDecorationTheme.contentPadding,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        labelStyle: TextStyle(color: AppThemeHSL.textMuted),

        // El borde dinámico que querías
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _selectedType == TransactionType.income
                ? AppThemeHSL.incomeDark.withValues(alpha: 0.3)
                : AppThemeHSL.expenseDark.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        border: InputBorder.none, // OutlineInputBorder(),
      ),
    );
  }

  Card _showPreviewAmount() {
    return Card(
      color: AppThemeHSL.surfaceLighter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              "Proyección Histórica",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppThemeHSL.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Impacto en saldo total:"),
                Text(
                  "\$${_previewTotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedType == TransactionType.expense
                        ? AppThemeHSL.expense
                        : AppThemeHSL.income,
                  ),
                ),
              ],
            ),
            Text(
              "Calculado desde ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} hasta hoy",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() async {
    final double? amount = double.tryParse(_amountController.text);
    if (_descController.text.isEmpty || amount == null || amount <= 0) {
      final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Text('No deben haber espacios vacíos');
      return;
    }

    if (widget.isBillMode) {
      // Lógica para Factura
      // Ahora pasamos los valores del estado del widget al objeto que se guarda en Hive:
      final newBill = Bill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _descController.text.toCapitalized(),
        amount: amount,
        dueDate: _selectedDate,
        recurrence: _selectedRecurrence, // <-- GUARDAR ESTO
        hasReminder: _createCalendarReminder, // <-- GUARDAR ESTO
      );

      // Esperamos a que el Notifier termine de guardar e invalidar
      await widget.onAddBill(newBill);

      if (_createCalendarReminder) {
        _crearRecordatorioCalendario(
          titulo: _descController.text.toCapitalized(),
          monto: amount,
          fecha: _selectedDate,
          frecuencia: _selectedRecurrence,
        );
      }
    } else {
      // Lógica para el nuevo modelo Transaction de Hive
      final newTx = Transaction(
        description: _descController.text.toCapitalized(),
        amount: amount,
        type: _selectedType,
        subCategory: _selectedSubCategory,
        date: _selectedDate,
        recurrence: _selectedRecurrence,
        // Extraemos el codePoint del icono que corresponde a la categoría
        iconCodePoint:
            (categoryIcons[_selectedSubCategory] ?? Icons.help_outline)
                .codePoint,
        recurrenceAmount: __calculatedRecurrence,
        // Asignamos un icono por defecto según el tipo para cumplir con el modelo
        // iconCodePoint: _selectedType == TransactionType.expense
        //     ? Icons.shopping_bag_outlined.codePoint
        //     : Icons.account_balance_wallet_outlined.codePoint,
      );

      await widget.onAdd(newTx);
    }

    // if (mounted) Navigator.pop(context); // Este Navigator.pop evita mostar el dialog
  }
}
