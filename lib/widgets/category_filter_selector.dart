import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class CategoryFilterSelector extends ConsumerStatefulWidget {
  final bool showTransactions;
  final Function(bool) onChanged;

  const CategoryFilterSelector({
    super.key,
    required this.showTransactions,
    required this.onChanged,
  });

  @override
  ConsumerState<CategoryFilterSelector> createState() =>
      _CategoryFilterSelectorState();
}

class _CategoryFilterSelectorState
    extends ConsumerState<CategoryFilterSelector> {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- DISEÑO ORIGINAL DEL SELECTOR (La Pastilla) ---
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
          height: 45,
          decoration: BoxDecoration(
            color: AppThemeHSL.surface,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: widget.showTransactions
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(true),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          'Movimientos',
                          style: TextStyle(
                            color: widget.showTransactions
                                ? Colors.black
                                : Colors.white60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(false),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          'Facturas',
                          style: TextStyle(
                            color: !widget.showTransactions
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
        ),
      ],
    );
  }
}
