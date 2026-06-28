// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/add_money_dialog.dart';

class AddMoneyDialogState extends State<AddMoneyDialog> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    // SIF: Liberamos el controlador de la memoria obligatoriamente
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeHSL.surface,
      title: Text(
        "Abonar a ${widget.goal.title}",
        style: const TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: "Monto a ahorrar"),
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final monto = double.tryParse(_amountController.text);
            if (monto != null && monto > 0) {
              widget.onAmountSubmitted(monto);
              Navigator.pop(context);
            }
          },
          child: const Text("Abonar"),
        ),
      ],
    );
  }
}
