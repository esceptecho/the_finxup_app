import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/screens/attachment_full_screen_viewer.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/utils/permission_service.dart';
import 'package:the_finxup_app/utils/share_service.dart';
import 'package:the_finxup_app/widgets/add_transaction_form.dart';
import 'package:the_finxup_app/widgets/expandible_info_section.dart';
import 'package:the_finxup_app/widgets/video_player_widget.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});


  void showAddCardModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionForm(
        
        initialTransaction: transaction,
        isBillMode: false,
        onAdd: (newTx) async => await ref
            .read(transactionListNotifierProvider.notifier)
            .addTransaction(newTx),
        onAddBill: (p0) {},
      ),
    );
  }

  void _deleteTransaction(String id, WidgetRef ref) {
    ref.read(transactionListNotifierProvider.notifier).deleteTransaction(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el valor histórico de esta transacción específica
    final valorHistorico = ref.watch(
      transaccionHistoricoProvider(transaction.id),
    );

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
            onPressed: () {
              showAddCardModal(context, ref);
              _deleteTransaction(transaction.id, ref);
            },
          ),
        ],
      ),

      /*
      body: RefreshIndicator(
        onRefresh: () async {
          // Forzar recálculo del provider
          ref.invalidate(transaccionHistoricoProvider(transaction.id));
          ref.invalidate(transactionListNotifierProvider);
        },
        color: AppThemeHSL.accentGold,
        child: LayoutBuilder(
      */
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Icono Principal Animado
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              width: 200,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppThemeHSL.accentGold.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: .center,
                                children: [
                                  Icon(
                                    IconData(
                                      // ignore: non_const_argument_for_const_parameter
                                      transaction.iconCodePoint,
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    size: 70,
                                    color: AppThemeHSL.accentGold,
                                  ),
                                  if (transaction.subCategory != null)
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        transaction.categoryDisplay
                                            .toUpperCase(),
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
                                bottom: 10,
                                right: 40,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemeHSL.accentGold.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppThemeHSL.accentGold.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        size: 11,
                                        color: AppThemeHSL.accentGold,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        transaction.recurrence
                                            .substring(0, 3)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: AppThemeHSL.accentGold,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 2. MONTO GIGANTE
                        Text(
                          transaction.recurrence != 'Única vez'
                              ? '${isIncome ? "+" : "-"}\$${valorHistorico.toStringAsFixed(2)}'
                              : '${isIncome ? "+" : "-"}\$${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: isIncome
                                ? AppThemeHSL.income
                                : AppThemeHSL.expense,
                            letterSpacing: -1,
                          ),
                        ),
                        // Y debajo, un subtítulo que aclare:
                        if (transaction.recurrence != 'Única vez' &&
                            valorHistorico > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "${transaction.amount.toStringAsFixed(2)}/período · Acumulado a hoy",
                              style: TextStyle(
                                color: AppThemeHSL.textHint.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
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

                        // 3. Descripción y Subcategoría
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
                        const SizedBox(height: 16),

                        // 5. ⭐ NUEVA SECCIÓN DE RECURRENCIA (reemplaza la anterior de NOTAS)
                        // Solo se muestra si la transacción tiene recurrencia configurada
                        // 5. Sección de recurrencia o información
                        if (transaction.recurrence != 'Única vez' &&
                            transaction.recurrence.isNotEmpty)
                          _buildRecurrenceInfoSection(
                            transaction,
                            valorHistorico,
                          )
                        else
                          // Reemplaza el _buildInfoSection actual por esto:
                          // Reemplaza el contenedor anterior por esto:
                          const VideoPlayerWidget(
                            videoUrl:
                                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                            title: '¿Cómo funciona la recurrencia?',
                            description:
                                'Aprende cómo las transacciones recurrentes '
                                'calculan automáticamente el acumulado desde la fecha '
                                'de inicio hasta hoy.',
                          ),

                        const SizedBox(height: 16),
                        // Características de ambas opciones:
                        // _buildInfoSection(...),

                        // Opción 1 - Control total
                        ExpandableInfoSection(
                          label: "INFORMACIÓN DE RECURRENCIA",
                          value: "Esta es una transacción ${transaction.recurrence}.\n\n"
                              "💡 Las transacciones recurrentes te permiten registrar ingresos o gastos "
                              "que se repiten periódicamente (diario, semanal, mensual, etc.).\n\n"
                              "Cuando configuras una recurrencia, la app calcula automáticamente:\n"
                              "• El monto acumulado desde la fecha de inicio hasta hoy\n"
                              "• La proyección total a un año\n"
                              "• Las ocurrencias restantes por devengar\n\n"
                              "Por ejemplo: Un salario mensual de \$3,000 iniciando en enero mostrará "
                              "\$15,000 acumulados en mayo (5 meses × \$3,000).\n\n"
                              "Para hacer esta transacción recurrente, edítala y selecciona "
                              "la frecuencia deseada.",
                          icon: Icons.info_outline_rounded,
                          initiallyExpanded: false,
                        ),

                        // Opción 2 - Animación simplificada
                        // AnimatedExpandableSection(
                        //   label: "INFORMACIÓN DE RECURRENCIA",
                        //   value: "Esta es una transacción ${transaction.recurrence}.\n\n"
                        //       "💡 Las transacciones recurrentes te permiten registrar ingresos o gastos "
                        //       "que se repiten periódicamente (diario, semanal, mensual, etc.).\n\n"
                        //       "Cuando configuras una recurrencia, la app calcula automáticamente:\n"
                        //       "• El monto acumulado desde la fecha de inicio hasta hoy\n",
                        //   icon: Icons.info_outline_rounded,
                        //   duration: Duration(milliseconds: 400), // Opcional
                        //   curve: Curves.easeOutCubic, // Opcional
                        // ),
                        // const SizedBox(height: 24),
                        // YoutubePlayerWidget(
                        //   videoUrl:
                        //       'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // https://www.youtube.com/watch?v=dQw4w9WgXcQ
                        //   title: '¿Cómo funciona la recurrencia?',
                        //   description:
                        //       'Aprende cómo las transacciones recurrentes '
                        //       'calculan automáticamente el acumulado.',
                        //       showInfo: true,
                        // ),
                        const SizedBox(height: 24),
                        // 6. Miniatura de Adjuntos (si existen)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (transaction.attachmentPaths.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    "No hay archivos adjuntos",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.start,
                                children: [
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

                        // 7. Botón de acción rápida
                        // Botón de acción rápida
                        // En el botón de compartir
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
                            onPressed: () async {
                              try {
                                await ShareService.shareTransaction(
                                  transaction: transaction,
                                  valorHistorico:
                                      transaction.recurrence != 'Única vez'
                                      ? valorHistorico
                                      : null,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al compartir: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
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

  Widget _buildRecurrenceInfoSection(
    Transaction transaction, //
    double valorHistorico,
  ) {
    // Si no tiene recurrencia configurada
    if (transaction.recurrence == 'Única vez' ||
        transaction.recurrence.isEmpty) {
      return _buildInfoSection(
        label: "TIPO DE TRANSACCIÓN",
        value: "Pago único — sin recurrencia",
        icon: Icons.receipt_long_rounded,
      );
    }

    final bool esIngreso = transaction.type == TransactionType.income;
    final String tipoTransaccion = esIngreso ? "Ingreso" : "Gasto";
    final String flecha = esIngreso ? "↑" : "↓";
    final Color accentColor = esIngreso
        ? const Color(0xFF4ADE80) // verde ingreso
        : const Color(0xFFF87171); // rojo gasto

    // Determinar cuántas ocurrencias han pasado y cuántas faltan
    final int ocurrenciasPasadas = valorHistorico > 0
        ? (valorHistorico / transaction.amount).round()
        : 0;
    final int ocurrenciasTotales = _calcularOcurrenciasTotales(
      transaction.recurrence,
    );
    final int ocurrenciasRestantes = ocurrenciasTotales - ocurrenciasPasadas;

    // Formatear el período en texto legible
    final String periodoTexto = _formatearPeriodo(transaction.recurrence);
    final String frecuenciaTexto = _formatearFrecuencia(transaction.recurrence);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la sección
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat_rounded, color: accentColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "RECURRENTE · $frecuenciaTexto",
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                "$flecha \$${transaction.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progreso visual de la recurrencia
          _buildProgressIndicator(
            ocurrenciasPasadas: ocurrenciasPasadas,
            ocurrenciasTotales: ocurrenciasTotales,
            accentColor: accentColor,
            transaction: transaction,
          ),

          const SizedBox(height: 16),

          // Detalles de acumulación
          Row(
            children: [
              _buildStatCard(
                label: "Acumulado hasta hoy",
                value: "\$${valorHistorico.toStringAsFixed(0)}",
                subtext: "$ocurrenciasPasadas $periodoTexto",
                color: accentColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: "Proyectado a 1 año",
                value:
                    "\$${(transaction.amount * ocurrenciasTotales).toStringAsFixed(0)}",
                subtext: "$ocurrenciasTotales $periodoTexto en total",
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),

          if (ocurrenciasRestantes > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: Color(0xFFFBBF24),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Quedan $ocurrenciasRestantes $periodoTexto por devengar "
                      "(\$${(transaction.amount * ocurrenciasRestantes).toStringAsFixed(0)})",
                      style: TextStyle(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget para la barra de progreso visual
  Widget _buildProgressIndicator({
    required int ocurrenciasPasadas,
    required int ocurrenciasTotales,
    required Color accentColor,
    required Transaction transaction,
  }) {
    final double progreso = ocurrenciasPasadas / ocurrenciasTotales;
    final int porcentaje = (progreso * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progreso de recurrencia",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              "$porcentaje%",
              style: TextStyle(
                color: accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progreso.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(widthFactor: value, child: child);
                },
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor.withValues(alpha: 0.6), accentColor],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Inicio: ${_formatearFecha(transaction.date)}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
              ),
            ),
            Text(
              "Fin: ${_calcularFechaFin(transaction.date, transaction.recurrence)}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tarjeta de estadística individual
  Widget _buildStatCard({
    required String label,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares de formateo
  int _calcularOcurrenciasTotales(String recurrence) {
    switch (recurrence) {
      case 'Diario':
        return 365;
      case 'Semanal':
        return 52;
      case 'Mensual':
        return 12;
      case 'Trimestral':
        return 4;
      case 'Semestral':
        return 2;
      case 'Anual':
        return 1;
      default:
        return 1;
    }
  }

  String _formatearPeriodo(String recurrence) {
    switch (recurrence) {
      case 'Diario':
        return 'días';
      case 'Semanal':
        return 'semanas';
      case 'Mensual':
        return 'meses';
      case 'Trimestral':
        return 'trimestres';
      case 'Semestral':
        return 'semestres';
      case 'Anual':
        return 'años';
      default:
        return 'períodos';
    }
  }

  String _formatearFrecuencia(String recurrence) {
    switch (recurrence) {
      case 'Diario':
        return 'DIARIO';
      case 'Semanal':
        return 'SEMANAL';
      case 'Mensual':
        return 'MENSUAL';
      case 'Trimestral':
        return 'TRIMESTRAL';
      case 'Semestral':
        return 'SEMESTRAL';
      case 'Anual':
        return 'ANUAL';
      default:
        return recurrence.toUpperCase();
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return "${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}";
  }

  String _calcularFechaFin(DateTime inicio, String recurrence) {
    final DateTime fin;
    switch (recurrence) {
      case 'Diario':
        fin = inicio.add(const Duration(days: 365));
        break;
      case 'Semanal':
        fin = inicio.add(const Duration(days: 364));
        break;
      case 'Mensual':
        fin = DateTime(inicio.year + 1, inicio.month, inicio.day);
        break;
      case 'Trimestral':
        fin = DateTime(inicio.year + 1, inicio.month, inicio.day);
        break;
      case 'Semestral':
        fin = DateTime(inicio.year + 1, inicio.month, inicio.day);
        break;
      case 'Anual':
        fin = DateTime(inicio.year + 1, inicio.month, inicio.day);
        break;
      default:
        fin = inicio;
    }
    return _formatearFecha(fin);
  }

  // Versión simplificada del _buildInfoSection original para otras notas
  Widget _buildInfoSection({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
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
      ),
    );
  }
}
