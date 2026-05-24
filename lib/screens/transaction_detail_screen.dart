import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/screens/attachment_full_screen_viewer.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/utils/permission_service.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final listNotifier = ref.read(transactionListNotifierProvider.notifier);
    // Determinamos si es gasto o ingreso para el color del monto
    final bool isIncome = transaction.type.toString().contains('income');

    return Scaffold(
      backgroundColor: AppThemeHSL.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () => print("Editar transacción"),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Hero(
                tag: 'tx_hero_${transaction.id}',
                // FlightShuttleBuilder evita errores visuales durante el "vuelo" del Hero
                flightShuttleBuilder:
                    (
                      flightContext,
                      animation,
                      direction,
                      fromContext,
                      toContext,
                    ) {
                      return SingleChildScrollView(child: toContext.widget);
                    },
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      // IMPORTANTE: min para que no intente expandirse más allá de sus hijos
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Icono Principal Animado
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppThemeHSL.accentGold.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    IconData(
                                      transaction.iconCodePoint,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    size: 56,
                                    color: AppThemeHSL.accentGold,
                                  ),
                                  if (transaction.subCategory != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        transaction.categoryDisplay
                                            .toUpperCase(), // <-- Usando el Getter

                                        style: TextStyle(
                                          color: AppThemeHSL.accentGold,
                                          fontSize: 10,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (transaction.recurrence != 'Única vez')
                              Positioned(
                                bottom: 20,
                                right: 10,
                                child: Tooltip(
                                  message: 'Transacción recurrente: ${transaction.recurrence}',
                                  child: Icon(
                                    Icons.repeat_on_rounded,
                                    size: 18,
                                    color: AppThemeHSL.accentGold,
                                    
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 3. MONTO GIGANTE
                        Text(
                          '${isIncome ? "+" : "-"}\$${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: isIncome
                                ? AppThemeHSL.income
                                : AppThemeHSL.expense,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          "${transaction.date.day} de ${_getMonthName(transaction.date.month)}, ${transaction.date.year}",
                          style: TextStyle(
                            color: AppThemeHSL.textHint,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. Descripción y Subcategoría
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: Text(
                              transaction.description,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: AppThemeHSL.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 24),

                        // 4. Sección de Información Adicional (Notas/Adjuntos)
                        _buildInfoSection(
                          label: "TIPO DE TRANSACCIÓN",
                          value: transaction.type
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          icon: Icons.swap_vert,
                        ),

                        const SizedBox(height: 24),

                        _buildInfoSection(
                          label: "NOTAS / COMENTARIOS",
                          value: transaction.recurrenceAmount != 0.0
                              ? "Valor de recurrencia en el tiempo: \$${transaction.recurrenceAmount}"
                              : "Sin notas adicionales para esta transacción.",
                          icon: Icons.notes,
                        ),
                        // const Divider(color: Colors.white10),
                        const SizedBox(height: 24),
                        // 5. Miniatura de Adjuntos (si existen)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                "ADJUNTOS",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing:
                                    12, // Espacio horizontal entre elementos
                                runSpacing: 12, // Espacio vertical entre líneas
                                alignment: WrapAlignment.start,
                                children: [
                                  // Usamos el operador spread (...) para convertir la lista de widgets en hijos del Wrap
                                  ..._buildAttachmentPreviews(
                                    transaction.attachmentPaths,
                                    context,
                                  ),
                                  _buildAddAttachmentButton(context, ref),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón de acción rápida
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined, size: 22),
                            label: const Text(
                              "COMPARTIR COMPROBANTE",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget auxiliar para las filas de información
  Widget _buildInfoSection({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppThemeHSL.accentGold, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[month - 1];
  }

  List<Widget> _buildAttachmentPreviews(
    List<String> paths,
    BuildContext context,
  ) {
    return paths.asMap().entries.map((entry) {
      int index = entry.key;
      String path = entry.value;

      final isImage = [
        '.jpg',
        '.jpeg',
        '.png',
      ].any((ext) => path.toLowerCase().endsWith(ext));

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AttachmentFullScreenViewer(paths: paths, initialIndex: index),
            ),
          );
        },
        child: Container(
          width: 80,
          height:
              80, // Definimos altura aquí ya que no hay ListView que la fuerce
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
            color: Colors.grey[900],
            image: isImage
                ? DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !isImage
              ? const Icon(Icons.description, color: Colors.white54)
              : null,
        ),
      );
    }).toList();
  }

  Widget _buildAddAttachmentButton(BuildContext context, WidgetRef ref) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, style: BorderStyle.solid),
      ),
      child: IconButton(
        onPressed: () async {
          // 1. Pedir el permiso usando nuestro nuevo servicio
          bool hasPermission = await PermissionService.requestStoragePermission(
            context,
          );

          if (hasPermission) {
            // 2. Si lo da, llamar al Notifier de Riverpod que creamos antes
            await ref
                .read(transactionListNotifierProvider.notifier)
                .addAttachmentToTransaction(transaction);
          }

          // Opcional: Manejar errores si el estado termina en error
          if (ref.read(transactionListNotifierProvider).hasError) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Error al subir el archivo')),
            );
          }
        },
        icon: Icon(Icons.add, color: Colors.white24),
      ),
    );
  }
}
