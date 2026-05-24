import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importante para usar Clipboard
import 'package:the_finxup_app/screens/tolerance_calculator_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import '../models/tolerance_case.dart';

class ToleranceCalculatorScreen0 extends StatefulWidget {
  const ToleranceCalculatorScreen0({super.key});

  @override
  State<ToleranceCalculatorScreen0> createState() =>
      _ToleranceCalculatorScreen0State();
}

class _ToleranceCalculatorScreen0State extends State<ToleranceCalculatorScreen0> {
  ToleranceCase _selectedCase = ToleranceCase.monthlyBudget;
  final TextEditingController _centerController = TextEditingController();
  final TextEditingController _toleranceController = TextEditingController();
  final TextEditingController _actualValueController = TextEditingController();

  double? _lowerBound;
  double? _upperBound;

  @override
  void initState() {
    super.initState();
    _updateDefaultValues();
  }

  // ¡CRÍTICO!: Liberar los controladores para evitar fugas de memoria
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
    _calculateRange();
  }

  void _calculateRange() {
    final double? center = double.tryParse(_centerController.text);
    final double? tolerance = double.tryParse(_toleranceController.text);

    if (center != null && tolerance != null && tolerance >= 0) {
      setState(() {
        _lowerBound = center - tolerance;
        _upperBound = center + tolerance;
      });
    } else {
      setState(() {
        _lowerBound = null;
        _upperBound = null;
      });
    }
  }

  String _getInequalityNotation() {
    final double? center = double.tryParse(_centerController.text);
    final double? tolerance = double.tryParse(_toleranceController.text);

    if (center == null || tolerance == null) return '|x - ?| ≤ ?';

    final centerStr = _formatNumber(center);
    final toleranceStr = _formatNumber(tolerance);

    return '|x - $centerStr| ≤ $toleranceStr';
  }

  // Ahora la función es asíncrona para manejar el portapapeles correctamente
  Future<void> _copyToClipboard(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_lowerBound != null && _upperBound != null) {
      final String result =
          'Intervalo: [${_formatNumber(_lowerBound!)}, ${_formatNumber(_upperBound!)}]\n'
          'Desigualdad: ${_getInequalityNotation()}\n'
          'Significado: ${_selectedCase.description}';

      // 1. Copiar al portapapeles real del dispositivo
      await Clipboard.setData(ClipboardData(text: result));

      // 2. Verificar que el widget siga montado antes de usar el contexto
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Resultado copiado al portapapeles'),
          behavior: SnackBarBehavior.floating, // Se ve más moderno
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  String _formatNumber(double n) {
    return n == n.toInt() ? n.toInt().toString() : n.toString();
  }

  String _evaluateStatus() {
    final double? actual = double.tryParse(_actualValueController.text);
    final double? center = double.tryParse(_centerController.text);
    final double? tolerance = double.tryParse(_toleranceController.text);

    if (actual == null || center == null || tolerance == null)
      return "Esperando datos...";

    // Aplicando la fórmula de valor absoluto
    double diferencia = (actual - center).abs();

    if (diferencia <= tolerance) {
      return "✅ Dentro del margen: El valor es aceptable.";
    } else {
      double excedente = diferencia - tolerance;
      return "⚠️ Desviación detectada: Te sales por ${excedente.toStringAsFixed(2)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Tolerancia'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de caso
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona un caso de uso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ToleranceCase>(
                        initialValue:
                            _selectedCase, // Corregido de initialValue a value
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ToleranceCase.values.map((case_) {
                          return DropdownMenuItem(
                            value: case_,
                            child: Text(case_.displayName),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCase = newValue;
                              _updateDefaultValues();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCase.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Entrada de datos
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _centerController,
                        decoration: InputDecoration(
                          labelText: _selectedCase.centerLabel,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.center_focus_strong),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true, // Permitir números negativos
                        ),
                        // Evitar que el usuario escriba letras
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'),
                          ),
                        ],
                        onChanged: (_) => _calculateRange(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _toleranceController,
                        decoration: InputDecoration(
                          labelText: _selectedCase.toleranceLabel,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.tune),
                          helperText: 'Debe ser un valor positivo (≥ 0)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        // La tolerancia no puede ser negativa
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        onChanged: (_) => _calculateRange(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resultados
              Card(
                elevation: 4,
                color: Colors.teal.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Resultado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_lowerBound != null && _upperBound != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade300),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Intervalo de tolerancia:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '[${_formatNumber(_lowerBound!)}, ${_formatNumber(_upperBound!)}]',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const Divider(height: 24),
                              Text(
                                'Desigualdad absoluta:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getInequalityNotation(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Divider(height: 24),
                              Text(
                                'Significado:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'El valor debe estar entre ${_formatNumber(_lowerBound!)} y ${_formatNumber(_upperBound!)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            'Ingresa valores válidos para calcular la tolerancia.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón copiar
              if (_lowerBound != null && _upperBound != null)
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text(
                    'Copiar resultado',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              const SizedBox(height: 24), // Espaciado extra al final
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ToleranceCalculatorScreen(),
            ),
          );
        },

        backgroundColor: AppThemeHSL.incomeDark,

        elevation: 4,

        heroTag:
            "ToleranceCalculatorScreen0", // Evita conflictos de hero animation si hay más de un FAB en la app

        enableFeedback: true, // Feedback táctil para mejor UX

        child: Icon(Icons.calculate, color: AppThemeHSL.textPrimary, size: 48),
      ),

      floatingActionButtonLocation: .miniEndFloat,
    );
  }
}
