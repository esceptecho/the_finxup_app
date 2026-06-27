import 'package:flutter/material.dart';

class ConverterHeader extends StatelessWidget {
  // Podrías pasarle un string dinámico con la última actualización
  final String? lastUpdated;

  const ConverterHeader({
    super.key,
    this.lastUpdated = "Justo ahora", // Valor por defecto para el ejemplo
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono estilizado como Badge moderno
/*         Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.currency_exchange_rounded, // Variante redondeada
            size:
                32, // Reducimos el tamaño del icono porque el contenedor le da volumen
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16), */

        // Título Principal
        Text(
          'Tasas en Tiempo Real',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w200,
            color: theme.colorScheme.onSurface,
            letterSpacing:
                -0.5, // Un tracking ligeramente cerrado se ve más premium en títulos
          ),
        ),
        const SizedBox(height: 6),

        // Subtítulo
        Text(
          'Convierte entre las principales monedas',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w100,
          ),
        ),

        // Indicador de "Tiempo Real" / Última actualización
        if (lastUpdated != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Un pequeño indicador verde parpadeante o fijo
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Actualizado: $lastUpdated',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
