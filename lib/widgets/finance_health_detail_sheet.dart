import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';

class FinancialHealthDetailsSheet extends ConsumerWidget {
  const FinancialHealthDetailsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeLogicProvider);

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
          ExpenseSubCategory.food: 'Comidas fuera',

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

              // Cabecera del Estado
              Row(
                children: [
                  Icon(health.icon, color: health.badgeColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      health.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Puntaje Actual: ${score.toStringAsFixed(0)} puntos",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 32),

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
}
