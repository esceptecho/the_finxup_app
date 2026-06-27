import 'package:flutter/material.dart';
import 'package:the_finxup_app/models/exchange_rate_response.dart';

class CurrencySelector extends StatelessWidget {
  final String label;
  final SupportedCurrency? currency;
  final String selectedCode;
  final ValueChanged<String?> onChanged;

  const CurrencySelector({
    super.key,
    required this.label,
    required this.currency,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (currency != null) ...[
          Text(currency!.flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedCode,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: label,
              border: UnderlineInputBorder(),
              // OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(12),
              // ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: AppCurrencies.currencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency.code,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      currency.code,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '(${currency.name})',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
