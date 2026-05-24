// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/utils/string_extensions.dart';
import '../models/goal.dart';

class AddGoalForm extends StatefulWidget {
  final Function(Goal) onAdd;
  final Goal? initialGoal;

  const AddGoalForm({super.key, required this.onAdd, this.initialGoal});

  @override
  State<AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends State<AddGoalForm> {
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  late String _selectedEmoji;
  DateTime _selectedDate = DateTime.now();

  final List<String> _emojis = [
    '💰',
    '🚗',
    '🏠',
    '✈️',
    '🎓',
    '🛡️',
    '💻',
    '🚲',
    '📱',
    '🎁',
    '🍽️',
    '🎉',
    '📚',
  ];

  @override
  void initState() {
    super.initState();
    // Si recibimos una meta, precargamos los datos; si no, vacío.
    _titleController = TextEditingController(
      text: widget.initialGoal?.title ?? '',
    );
    _targetController = TextEditingController(
      text: widget.initialGoal?.targetAmount.toString() ?? '',
    );
    _currentController = TextEditingController(
      text: widget.initialGoal?.currentAmount.toString() ?? '',
    );
    _selectedEmoji = widget.initialGoal?.emoji ?? '💰';

    if (widget.initialGoal != null) {
      _selectedDate = widget.initialGoal!.targetDate;
    }
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
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppThemeHSL.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nueva Meta de Ahorro",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemeHSL.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Selector de Emoji
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _emojis.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => _selectedEmoji = _emojis[index]),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedEmoji == _emojis[index]
                        ? AppThemeHSL.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _emojis[index],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '¿Qué estás ahorrando?',
              floatingLabelStyle: TextStyle(
                color: AppThemeHSL.textPrimary.withOpacity(0.8),
              ),
            ),
            style: TextStyle(color: AppThemeHSL.textPrimary),
            cursorColor: AppThemeHSL.textPrimary,
          ),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto Objetivo (\$)',
              floatingLabelStyle: TextStyle(
                color: AppThemeHSL.textPrimary.withOpacity(0.8),
              ),
            ),
            style: TextStyle(color: AppThemeHSL.textPrimary),
            cursorColor: AppThemeHSL.textPrimary,
          ),
          TextField(
            controller: _currentController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto Inicial (Opcional)',
              floatingLabelStyle: TextStyle(
                color: AppThemeHSL.textPrimary.withOpacity(0.8),
              ),
            ),
            style: TextStyle(color: AppThemeHSL.textPrimary),
            cursorColor: AppThemeHSL.textPrimary,
          ),

          // Selector de Fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fecha objetivo: ${DateFormat.yMMMd('es_ES').format(_selectedDate)}',
                style: TextStyle(
                  color: AppThemeHSL.textSecondary,
                  fontSize: 14,
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.edit_calendar_outlined,
                  color: AppThemeHSL.primaryExtraLight.withValues(alpha: 0.8),
                  size: 24,
                ),
                label: Text(
                  'Cambiar',
                  style: TextStyle(
                    color: AppThemeHSL.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                onPressed: _presentDatePicker,
              ),
            ],
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeHSL.primary,
              ),
              onPressed: () async {
                final target = double.tryParse(_targetController.text);
                if (_titleController.text.isEmpty || target == null) return;

                final messenger = ScaffoldMessenger.of(
                  context,
                ); // Capturas lo necesario del contexto
                final nav = Navigator.of(context); // CAPTURAS EL NAVIGATOR AQUÍ

                final newGoal = Goal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.toTitleCase(), 
                  targetAmount: target,
                  currentAmount:
                      double.tryParse(_currentController.text) ?? 0.0,
                  emoji: _selectedEmoji,
                  targetDate:
                      _selectedDate, // coregir dateTarget con fecha seleccionad por el usuario
                );

                // Ejecutas la lógica
                await widget.onAdd(newGoal);

                // Usas la referencia guardada, no el 'context' directo si este ya cambió
                if (nav.canPop()) {
                  nav.pop();
                }
                // Muestras el banner de éxito
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Meta "${newGoal.title}" creada exitosamente 🎉',
                    ),
                  ),
                );
              },
              child: const Text(
                "Crear Meta",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
