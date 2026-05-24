import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_finxup_app/screens/tolerance_calculator_screen0.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import '../models/tolerance_case.dart';

class ToleranceCalculatorScreen extends StatefulWidget {
  const ToleranceCalculatorScreen({super.key});

  @override
  State<ToleranceCalculatorScreen> createState() =>
      _ToleranceCalculatorScreenState();
}

class _ToleranceCalculatorScreenState extends State<ToleranceCalculatorScreen> {
  ToleranceCase _selectedCase = ToleranceCase.monthlyBudget;

  // Controladores
  final TextEditingController _centerController = TextEditingController();
  final TextEditingController _toleranceController = TextEditingController();
  final TextEditingController _actualValueController = TextEditingController();

  double? _lowerBound;
  double? _upperBound;
  bool _isValid = true;
  double _deviation = 0;

  @override
  void initState() {
    super.initState();
    _updateDefaultValues();
  }

  @override
  void dispose() {
    _centerController.dispose();
    _toleranceController.dispose();
    _actualValueController.dispose();
    super.dispose();
  }

  void _updateDefaultValues() {
    final (center, tolerance) = _selectedCase.getDefaultValues();
    _centerController.text = center.toString();
    _toleranceController.text = tolerance.toString();
    _actualValueController.clear();
    _calculate();
  }

  void _calculate() {
    final double? center = double.tryParse(_centerController.text);
    final double? tolerance = double.tryParse(_toleranceController.text);
    final double? actual = double.tryParse(_actualValueController.text);

    if (center != null && tolerance != null && tolerance >= 0) {
      setState(() {
        _lowerBound = center - tolerance;
        _upperBound = center + tolerance;

        if (actual != null) {
          // Aplicación de la inecuación: |x - c| <= r
          _deviation = (actual - center).abs();
          _isValid = _deviation <= tolerance;
        } else {
          _isValid = true; // Por defecto si no hay valor real
        }
      });
    } else {
      setState(() {
        _lowerBound = null;
        _upperBound = null;
      });
    }
  }

  String _formatNumber(double n) =>
      n == n.toInt() ? n.toInt().toString() : n.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final bool hasActualValue = _actualValueController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditor Financiero'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Configuración del Caso
            _buildSectionTitle('Configuración del Caso'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<ToleranceCase>(
                  initialValue: _selectedCase,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: ToleranceCase.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCase = val;
                        _updateDefaultValues();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Parámetros de la Inecuación
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    _centerController,
                    _selectedCase.centerLabel,
                    Icons.center_focus_strong,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    _toleranceController,
                    _selectedCase.toleranceLabel,
                    Icons.tune,
                    isPositiveOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Auditoría: Valor Real (x)
            _buildSectionTitle('Auditoría en Tiempo Real'),
            _buildInputField(
              _actualValueController,
              'Ingrese valor actual para validar',
              Icons.account_balance_wallet,
              color: Colors.teal.shade700,
              highlight: true,
            ),
            const SizedBox(height: 24),

            // 4. Panel de Resultado Dinámico
            if (_lowerBound != null && _upperBound != null)
              _buildResultPanel(hasActualValue),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ToleranceCalculatorScreen0()));
        },
        backgroundColor: AppThemeHSL.incomeDark,
        elevation: 4,
        heroTag:
            "ToleranceCalculatorScreen0", // Evita conflictos de hero animation si hay más de un FAB en la app
        enableFeedback: true, // Feedback táctil para mejor UX
        child: Icon(Icons.calculate, color: AppThemeHSL.textPrimary, size: 48,),
      ),
      floatingActionButtonLocation: .miniEndFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPositiveOnly = false,
    Color? color,
    bool highlight = false,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => _calculate(),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(isPositiveOnly ? r'^\d*\.?\d*' : r'^-?\d*\.?\d*'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: const OutlineInputBorder(),
        focusedBorder: highlight
            ? OutlineInputBorder(
                borderSide: BorderSide(color: color ?? Colors.teal, width: 2),
              )
            : null,
      ),
    );
  }

  Widget _buildResultPanel(bool hasActualValue) {
    final Color statusColor = hasActualValue
        ? (_isValid ? Colors.green : Colors.red)
        : Colors.teal;

    return Card(
      color: statusColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasActualValue
                      ? (_isValid ? Icons.check_circle : Icons.error)
                      : Icons.info,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  hasActualValue
                      ? (_isValid ? 'DENTRO DEL MARGEN' : 'FUERA DE RANGO')
                      : 'RANGO CALCULADO',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Intervalo Aceptable: [${_formatNumber(_lowerBound!)}, ${_formatNumber(_upperBound!)}]',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '|x - ${_formatNumber(double.tryParse(_centerController.text) ?? 0)}| ≤ ${_formatNumber(double.tryParse(_toleranceController.text) ?? 0)}',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey,
              ),
            ),
            if (hasActualValue && !_isValid) ...[
              const SizedBox(height: 12),
              Text(
                'Desviación: +${_formatNumber(_deviation - double.parse(_toleranceController.text))}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

