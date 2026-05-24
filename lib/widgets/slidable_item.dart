import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class SlidableItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus; // Para facturas (pagado/pendiente)

  const SlidableItem({
    required this.child,
    required this.onDelete,
    this.onEdit,
    this.onToggleStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onToggleStatus != null)
            SlidableAction(
              onPressed: (_) => onToggleStatus!(),
              backgroundColor: AppThemeHSL.income,
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: 'Pagar',
            ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppThemeHSL.expense,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Borrar',
          ),
        ],
      ),
      child: child,
    );
  }
}