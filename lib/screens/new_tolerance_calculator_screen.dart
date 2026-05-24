import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_finxup_app/screens/tolerance_calculator_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import '../models/tolerance_case.dart';

class NewToleranceCalculatorScreen extends StatefulWidget {
  const NewToleranceCalculatorScreen({super.key});

  @override
  State<NewToleranceCalculatorScreen> createState() =>
      _NewToleranceCalculatorScreenState();
}

class _NewToleranceCalculatorScreenState extends State<NewToleranceCalculatorScreen> {
  final TextEditingController _centerController = TextEditingController();
  final TextEditingController _toleranceController = TextEditingController();
  final TextEditingController _actualValueController = TextEditingController();

  ToleranceCase _selectedCase = ToleranceCase.monthlyBudget;
  double _center = 500;
  double _tolerance = 50;
  double? _actualValue;

  @override
  void initState() {
    super.initState();
    _updateFieldsFromCase();
  }

  void _updateFieldsFromCase() {
    final (c, t) = _selectedCase.getDefaultValues();
    _centerController.text = c.toString();
    _toleranceController.text = t.toString();
    _actualValueController.clear();
    _updateValues();
  }

  void _updateValues() {
    setState(() {
      _center = double.tryParse(_centerController.text) ?? 0;
      _tolerance = double.tryParse(_toleranceController.text) ?? 0;
      _actualValue = double.tryParse(_actualValueController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isWithinTolerance =
        _actualValue == null || (_actualValue! - _center).abs() <= _tolerance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditor de Inecuaciones'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de caso
            DropdownButtonFormField<ToleranceCase>(
              value: _selectedCase,
              items: ToleranceCase.values
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(e.displayName)),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  _selectedCase = val;
                  _updateFieldsFromCase();
                }
              },
              decoration: const InputDecoration(labelText: 'Caso Financiero'),
            ),
            const SizedBox(height: 20),

            // Entradas numéricas
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    _centerController,
                    _selectedCase.centerLabel,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInput(
                    _toleranceController,
                    _selectedCase.toleranceLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Entrada de valor real (x)
            _buildInput(
              _actualValueController,
              'Valor Real a evaluar (x)',
              isHighlight: true,
            ),

            const SizedBox(height: 40),

            // --- LA BARRA DE PROGRESO DE INECUACIÓN ---
            _buildVisualInequality(isWithinTolerance),

            const SizedBox(height: 30),

            // Resumen de la inecuación
            _buildSummaryCard(isWithinTolerance),
          ],
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
            "NewToleranceCalculatorScreen0", // Evita conflictos de hero animation si hay más de un FAB en la app

        enableFeedback: true, // Feedback táctil para mejor UX

        child: Icon(Icons.calculate, color: AppThemeHSL.textPrimary, size: 48),
      ),

      floatingActionButtonLocation: .miniEndFloat,
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    bool isHighlight = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _updateValues(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isHighlight ? Colors.orange : Colors.teal,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildVisualInequality(bool isValid) {
    return Column(
      children: [
        const Text(
          "Visualización: |x - c| ≤ r",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),
        Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomPaint(
            painter: InequalityPainter(
              center: _center,
              tolerance: _tolerance,
              actualValue: _actualValue,
              isValid: isValid,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_format(_center - _tolerance * 2)), // Límite visual izq
            Text(
              "Centro: ${_format(_center)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_format(_center + _tolerance * 2)), // Límite visual der
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(bool isValid) {
    final color = _actualValue == null
        ? Colors.blueGrey
        : (isValid ? Colors.green : Colors.red);
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              _actualValue == null
                  ? "Esperando valor real..."
                  : (isValid ? "¡CUMPLE!" : "FUERA DE RANGO"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Intervalo: [${_format(_center - _tolerance)}, ${_format(_center + _tolerance)}]",
            ),
            if (_actualValue != null)
              Text(
                "Desviación absoluta: ${_format((_actualValue! - _center).abs())}",
              ),
          ],
        ),
      ),
    );
  }

  String _format(double n) => n.toStringAsFixed(n == n.toInt() ? 0 : 1);
}

// --- PAINTER PARA LA BARRA DE INECUACIÓN ---
class InequalityPainter extends CustomPainter {
  final double center;
  final double tolerance;
  final double? actualValue;
  final bool isValid;

  InequalityPainter({
    required this.center,
    required this.tolerance,
    this.actualValue,
    required this.isValid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // 1. Dibujar línea base
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // 2. Definir escala (mostramos desde c - 2r hasta c + 2r)
    double viewRange = tolerance * 2;
    if (viewRange == 0) viewRange = 1; // Evitar división por cero

    double getX(double value) {
      double relativePos = (value - (center - viewRange)) / (viewRange * 2);
      return relativePos.clamp(0.0, 1.0) * size.width;
    }

    // 3. Dibujar zona de tolerancia (Verde)
    paint.color = Colors.green.withOpacity(0.4);
    paint.strokeWidth = 20;
    canvas.drawLine(
      Offset(getX(center - tolerance), size.height / 2),
      Offset(getX(center + tolerance), size.height / 2),
      paint,
    );

    // 4. Marca del Centro (c)
    paint.color = Colors.teal;
    canvas.drawCircle(Offset(getX(center), size.height / 2), 8, paint);

    // 5. Marca del Valor Real (x)
    if (actualValue != null) {
      paint.color = isValid ? Colors.green : Colors.red;
      final xPos = getX(actualValue!);

      // Dibujar puntero (triángulo o línea gruesa)
      canvas.drawCircle(
        Offset(xPos, size.height / 2),
        12,
        paint..style = PaintingStyle.fill,
      );

      // Etiqueta "x"
      // --- DENTRO DEL MÉTODO paint DEL InequalityPainter ---

      if (actualValue != null) {
        paint.color = isValid ? Colors.green : Colors.red;
        final xPos = getX(actualValue!);

        // 1. Dibujar el círculo del indicador
        canvas.drawCircle(
          Offset(xPos, size.height / 2),
          12,
          paint..style = PaintingStyle.fill,
        );

        // 2. Corregir el TextPainter:
        final textPainter = TextPainter(
          text: TextSpan(
            text: "x",
            style: TextStyle(
              color: paint.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        // Llamadas separadas para evitar errores de 'void'
        textPainter.layout();
        textPainter.paint(canvas, Offset(xPos - 5, size.height / 2 - 35));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
