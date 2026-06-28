// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/widgets/add_money_dialog_state.dart';

class AddMoneyDialog extends StatefulWidget {
  final Goal goal;
  final ValueChanged<double> onAmountSubmitted;

  const AddMoneyDialog({
    super.key,
    required this.goal,
    required this.onAmountSubmitted,
  });

  @override
  State<AddMoneyDialog> createState() => AddMoneyDialogState();
}
