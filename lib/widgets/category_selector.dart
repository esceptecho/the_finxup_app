import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class CategorySelector extends StatelessWidget {
  final bool showTransactions;
  final Function(bool) onChanged;

  const CategorySelector({
    super.key,
    required this.showTransactions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) { 
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      height: 45,
      decoration: BoxDecoration(
        color: AppThemeHSL.surface,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Animación de la "pastilla" blanca
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: showTransactions
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
              ),
            ),
          ),
          // Botones de texto
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Movimientos',
                      style: TextStyle(
                        color: showTransactions ? Colors.black : Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Facturas',
                      style: TextStyle(
                        color: !showTransactions
                            ? Colors.black
                            : Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
