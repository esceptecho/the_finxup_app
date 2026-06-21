import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
// import 'package:the_finxup_app/models/ds_life_style_profile.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/ds_final_finance_analytics_engine.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class FinancialHealthDetailsSheet extends ConsumerWidget {
  const FinancialHealthDetailsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(dsFinanceLogicProvider);

    return financeAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(
        height: 200,
        child: Center(child: Text('Error al cargar detalles')),
      ),
      data: (engine) {
        final health = engine.getHealthStatusProfile();
        final score = engine.getFinancialHealthIndex();

        // Categorías para mostrar en el desglose de "Gastos de Estilo de Vida"
        final lifestyleCategories = {
          // Ocio y entretenimiento
          ExpenseSubCategory.leisure: 'Ocio/Entretenimiento',
          ExpenseSubCategory.entertainment: 'Ocio/Entretenimiento',
          ExpenseSubCategory.online: 'Ocio/Entretenimiento',
          ExpenseSubCategory.subscription: 'Ocio/Entretenimiento',

          // Comidas y bebidas fuera de casa o rápidas
          ExpenseSubCategory.coffee: 'Cafecitos',
          ExpenseSubCategory.snacks: 'Antojos/Snacks',
          ExpenseSubCategory.delivery: 'Delivery',
          ExpenseSubCategory.restaurant: 'Comidas fuera',

          // Compras personales
          ExpenseSubCategory.shopping: 'Compras/Caprichos',
          ExpenseSubCategory.clothing: 'Compras/Caprichos',
          ExpenseSubCategory.electronics: 'Compras/Caprichos',
          ExpenseSubCategory.impulsive: 'Compras/Caprichos',
          ExpenseSubCategory.gifts: 'Regalos',

          // Viajes y movilidad
          ExpenseSubCategory.travel: 'Viajes',
          ExpenseSubCategory.transport: 'Transporte',
          ExpenseSubCategory.tolls: 'Peajes',
          ExpenseSubCategory.parking: 'Estacionamiento',

          // Salud y bienestar
          ExpenseSubCategory.gym: 'Salud/Bienestar',
          ExpenseSubCategory.health: 'Salud/Bienestar',
          ExpenseSubCategory.beauty: 'Salud/Bienestar',

          // Hogar y servicios
          ExpenseSubCategory.rent: 'Hogar/Alquiler',
          ExpenseSubCategory.services: 'Servicios',
          ExpenseSubCategory.repairs: 'Reparaciones',
          ExpenseSubCategory.homeImprovement: 'Mejoras del hogar',

          // Mascotas
          ExpenseSubCategory.pets: 'Mascotas',

          // Niños
          ExpenseSubCategory.kids: 'Hijos',

          // Educación
          ExpenseSubCategory.education: 'Educación',

          // Financieros
          ExpenseSubCategory.insurance: 'Seguros',
          ExpenseSubCategory.interest: 'Intereses',
          ExpenseSubCategory.taxes: 'Impuestos',

          // Ahorros
          ExpenseSubCategory.savings: 'Ahorro',

          // Otros
          ExpenseSubCategory.charity: 'Donaciones',
          ExpenseSubCategory.offerings: 'Ofrendas/Donaciones',
          ExpenseSubCategory.others: 'Otros',
        };

        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Línea superior decorativa del BottomSheet
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildHealthScoreCard(engine, context),
              const SizedBox(height: 16),
              // Cabecera del Estado
              // Row(
              //   children: [
              //     Icon(health.icon, color: health.badgeColor, size: 28),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: Text(
              //         health.label,
              //         style: const TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 8),
              // Text(
              //   "Puntaje Actual: ${score.toStringAsFixed(0)} puntos",
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: Colors.grey[600],
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              // const Divider(height: 32),

              // Explicación matemática simplificada de la fórmula: 3(Positivos) - 4(Negativos)
              const Text(
                "¿Cómo se calcula tu salud financiera?",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Premiamos tus hábitos de ahorro e inversión (x3) y penalizamos de forma progresiva los excesos en gastos variables y hormiga (x4).",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Desglose de Gastos Hormiga / Ocio
              const Text(
                "Impacto de tu Estilo de Vida:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Lista dinámica de lo gastado en cada subcategoría de ocio
              ...lifestyleCategories.entries.map((entry) {
                final totalSpent = engine.getTotalExpenseByCategory(entry.key);
                if (totalSpent == 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        "-\$${totalSpent.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Alerta de Penalización por exceso (Si supera los $150 de tu fórmula)
              _buildPenaltyWarning(engine),

              // const SizedBox(height: 24),
              // _buildHealthScoreCard(engine, context),
              const SizedBox(height: 24),

              // Botón de cierre
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Entendido",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget auxiliar para calcular y mostrar si el usuario cruzó la línea roja de los $150
  Widget _buildPenaltyWarning(FinanceAnalyticsEngine engine) {
    // Replicamos la constante de control de tu algoritmo
    double totalLifestyle = 0.0;
    final lifestyleCategories = {
      ExpenseSubCategory.leisure,
      ExpenseSubCategory.entertainment,
      ExpenseSubCategory.coffee,
      ExpenseSubCategory.snacks,
      ExpenseSubCategory.delivery,
      ExpenseSubCategory.shopping,
      ExpenseSubCategory.travel,
    };

    for (var t in engine.transactions) {
      if (t.type == TransactionType.expense &&
          lifestyleCategories.contains(t.subCategory)) {
        totalLifestyle += t.amount;
      }
    }

    if (totalLifestyle > 150.0) {
      final excess = totalLifestyle - 150.0;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber[700]!, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.gavel_rounded, color: Colors.amber[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "¡Alerta de Exceso! Superaste el límite saludable de \$150 en ocio por \$${excess.toStringAsFixed(2)}. Este excedente te castiga un 150% más en tu índice.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "¡Buen control! Tus gastos de estilo de vida se mantienen por debajo del umbral de penalización crítico (\$150).",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO REDISEÑADOS ---
  Widget _buildHealthScoreCard(
    FinanceAnalyticsEngine engine,
    BuildContext context,
  ) {
    final score = engine.getFinancialHealthIndex();
    final healthProfile = engine.getHealthStatusProfile();
    final bool isScorePositive = score >= 0;

    return GestureDetector(
      onTap: () => _showHealthProfileDetails(context, engine),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isScorePositive
                ? [AppThemeHSL.incomeDark, AppThemeHSL.income]
                : [AppThemeHSL.expenseLight, AppThemeHSL.expense],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color:
                  (isScorePositive
                          ? AppThemeHSL.incomeDark
                          : AppThemeHSL.expense)
                      .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animación Lottie de fondo reactiva
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.9,
                child: Lottie.asset(
                  isScorePositive
                      ? 'assets/lotties/Man_flyingairplane.json'
                      : 'assets/lotties/warning_pulse.json',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Índice de Salud Financiera",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        score.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "pts",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Badge dinámico con el perfil de salud
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: healthProfile.badgeColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          healthProfile.icon,
                          color: healthProfile.badgeColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          healthProfile.label,
                          style: TextStyle(
                            color: healthProfile.badgeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo detallado que muestra la descripción completa del perfil de salud
  void _showHealthProfileDetails(
    BuildContext context,
    FinanceAnalyticsEngine engine,
  ) {
    final healthProfile = engine.getHealthStatusProfile();
    final score = engine.getFinancialHealthIndex();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemeHSL.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(healthProfile.icon, color: healthProfile.badgeColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                healthProfile.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              "Puntuación:",
              "${score.toStringAsFixed(0)} pts",
              healthProfile.badgeColor,
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Text(
              healthProfile.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            // Información adicional: días de liquidez si es baja
            if (engine.predictDaysOfLiquidity() < 15) ...[
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.cyanAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "⚠️ Liquidez limitada: ${engine.predictDaysOfLiquidity().toStringAsFixed(0)} días restantes.",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Entendido",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para filas de detalle (puedes reutilizar el que ya tienes)
  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
