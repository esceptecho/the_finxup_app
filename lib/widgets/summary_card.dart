import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:the_finxup_app/models/life_style_profile.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/finance_health_detail_sheet.dart';

class SummaryCard extends ConsumerWidget {
  final String userName;
  final VoidCallback? onCloseTap;
  final VoidCallback? onDetailsTap;

  const SummaryCard({
    super.key,
    required this.userName,
    this.onCloseTap,
    this.onDetailsTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Color _getHealthColor(double index) {
    if (index > 500) return Colors.greenAccent;
    if (index > 0) return Colors.tealAccent;
    if (index > -200) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  // Método fuera del build
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite bottom sheet a pantalla completa
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FinancialHealthDetailsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos los cambios en las transacciones para recalcular todo en vivo
    final financeAsync = ref.watch(financeLogicProvider);

    // 2. Extraemos la analítica avanzada de tu Notifier
    return financeAsync.when(
      loading: () =>
          const Card(child: Center(child: CircularProgressIndicator())),
      error: (err, _) =>
          const Card(child: Center(child: Text('Error analítico'))),
      data: (engine) {
        // Extraemos toda la analítica en vivo de tu clase unificada
        final profile = engine.getLifestyleLevel();
        final profileLttie = engine.getLifestyleLevelLottie();
        final healthIndex = engine.getFinancialHealthIndex();
        final liquidityDays = engine.predictDaysOfLiquidity();
        final foodTrend = engine.getFoodSpendingTrend();

        return Card(
          margin: const EdgeInsets.all(4.0),
          elevation: 6,
          // shadowColor: AppThemeHSL.textMuted.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppThemeHSL.surface, AppThemeHSL.surfaceMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ENCABEZADO: Saludo y Perfil de Estilo de Vida ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()},',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge dinámico según el perfil devuelto por tu algoritmo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (onCloseTap != null) ...[
                      // const SizedBox(width: 8),
                      // IconButton(
                      //   onPressed: onCloseTap,
                      //   icon: const Icon(Icons.close_rounded, size: 18),
                      //   color: Colors.white.withValues(alpha: 0.6),
                      //   style: IconButton.styleFrom(
                      //     backgroundColor: Colors.white.withValues(alpha: 0.08),
                      //   ),
                      // ),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // --- CUADRÍCULA (GRID VIEW): Tus Métricas del Notifier ---
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                      0.95, // Ajuste para que quepa icono + valor + label
                  children: [
                    // Métrica 1: Índice de Salud
                    _buildMetricTile(
                      icon: Icons.favorite_rounded,
                      iconColor: _getHealthColor(healthIndex),
                      value: "${healthIndex.toStringAsFixed(0)} pts",
                      label: 'Salud Financiera',
                      onTap: () => _showBottomSheet(context),
                    ),
                    // Métrica 2: Días de Liquidez (Fórmula cuadrática)
                    _buildMetricTile(
                      icon: Icons.hourglass_top_rounded,
                      iconColor: liquidityDays > 7
                          ? Colors.lightBlueAccent
                          : Colors.amberAccent,
                      value: liquidityDays == 0
                          ? '0'
                          : liquidityDays.toStringAsFixed(0),
                      label: 'Días de Liquidez',
                      onTap: () {
                        Navigator.pushNamed(context, '/analytics');
                      },
                    ),
                    // Métrica 3: Tendencia de Comida (Intervalo de crecimiento)
                    _buildMetricTile(
                      icon: Icons.restaurant_rounded,
                      iconColor: Colors.purpleAccent,
                      value: foodTrend
                          .split(' ')
                          .first, // Separa el texto del emoji si deseas
                      label: 'Gasto Alimentos',
                      suffixWidget: Text(
                        foodTrend.contains('📈')
                            ? '📈'
                            : (foodTrend.contains('📉') ? '📉' : '➖'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- PIE DE TARJETA: Estado de Alerta Interactivo ---
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showLifestyleProfileDialogLottie(context, profileLttie,
                    ),
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profile.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onDetailsTap != null)
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showLifestyleProfileDialog(
  //   BuildContext context, LifestyleProfile profile) {
  //   final statusColor = _getStatusColor(profile.statusColor);

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: AppThemeHSL.surface,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Row(
  //         children: [
  //           if (profile.lottieAsset == null)
  //             Icon(Icons.psychology_alt, color: statusColor, size: 28)
  //           else
  //             SizedBox(
  //               width: 40,
  //               height: 40,
  //               child: Lottie.asset(
  //                 profile.lottieAsset!,
  //                 fit: BoxFit.contain,
  //                 repeat: profile.loopLottie,
  //               ),
  //             ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Text(
  //               profile.name,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           if (profile.lottieAsset != null)
  //             Container(
  //               width: double.infinity,
  //               height: profile.lottieHeight,
  //               margin: const EdgeInsets.only(bottom: 16),
  //               child: Lottie.asset(
  //                 profile.lottieAsset!,
  //                 fit: BoxFit.contain,
  //                 repeat: profile.loopLottie,
  //                 reverse: false,
  //                 animate: true,
  //               ),
  //             ),
  //           _buildMessageCard(profile.message, statusColor),
  //           const SizedBox(height: 16),
  //           _buildAdviceCard(profile.advice, statusColor),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           style: TextButton.styleFrom(foregroundColor: statusColor),
  //           child: const Text("Entendido"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // void _showLifestyleProfileDialog(BuildContext context, LifestyleProfile profile) {
// Diálogo actualizado
  void _showLifestyleProfileDialogLottie(
    BuildContext context,
    LifestyleProfile profile) {
    final statusColor = _getStatusColor(profile.statusColor);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9), // 70% opaco (más oscuro)
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeHSL.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            if (profile.lottieAsset == null)
              Icon(Icons.psychology_alt, color: statusColor, size: 28)
            else
              SizedBox(
                width: 40,
                height: 40,
                child: Lottie.asset(
                  profile.lottieAsset!,
                  fit: BoxFit.contain,
                  repeat: profile.loopLottie,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                profile.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profile.lottieAsset != null)
              Container(
                width: double.infinity,
                height: profile.lottieHeight,
                margin: const EdgeInsets.only(bottom: 16),
                child: Lottie.asset(
                  profile.lottieAsset!,
                  fit: BoxFit.contain,
                  repeat: profile.loopLottie,
                  reverse: false,
                  animate: true,
                ),
              ),
            _buildMessageCard(profile.message, statusColor),
            const SizedBox(height: 16),
            _buildAdviceCard(profile.advice, statusColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: statusColor),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(String advice, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para obtener el color según el string
  Color _getStatusColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blueAccent;
      case 'green':
        return Colors.greenAccent;
      case 'orange':
        return Colors.orangeAccent;
      case 'red':
        return Colors.redAccent;
      case 'purple':
        return Colors.purpleAccent;
      default:
        return Colors.blueAccent;
    }
  }

  // Helper Widget para construir los bloques de la cuadrícula de forma limpia
  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTap, // Tipo correcto: VoidCallback
    Widget? suffixWidget,
  }) {
    return Material(
      color: Colors.transparent, // Importante: transparente
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          7,
        ), // Para que el ripple respete el borde
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (suffixWidget != null) ...[
                      const SizedBox(width: 4),
                      suffixWidget,
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
