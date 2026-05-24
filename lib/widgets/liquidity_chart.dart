import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/final_finance_analytics_engine.dart';
// import 'package:the_finxup_app/providers/finance_analytics_engine.dart';
// import 'package:the_finxup_app/providers/finance_logic_provider.dart';

class LiquidityChart extends StatelessWidget {
  final FinanceAnalyticsEngine engine;

  const LiquidityChart({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final double daysLeft = engine.predictDaysOfLiquidity();
    final DateTime today = DateTime.now();
    final DateTime bankruptcyDate = today.add(Duration(days: daysLeft.toInt()));

    final String startDateStr = DateFormat('dd MMM').format(today);
    final String endDateStr = daysLeft > 0
        ? DateFormat('dd MMM').format(bankruptcyDate)
        : "N/A";
        
    // Generamos los puntos de la curva f(t) = at² + bt + c
    List<FlSpot> spots = _generateProjectionSpots();

    return Container(
      height: 380,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        // Fondo oscuro profundo con bordes redondeados
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Proyección de Liquidez",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Simulación basada en f(t) = at² + bt + c",
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Título y Subtítulo
          _buildHeader(daysLeft, endDateStr),

          const SizedBox(height: 24),
          Expanded(
            child: Hero(
              tag: '_buildLiquidityCard',
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    show: false,
                  ), // Mantiene estética limpia
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      // Gradiente de color para la línea (Azul a Cian Neón)
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      ),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      // Área debajo de la curva con gradiente sutil
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4FACFE).withValues(alpha: 0.2),
                            const Color(0xFF00F2FE).withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  // Comportamiento al tocar la gráfica
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => const Color(0xFF252545),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'Día ${spot.x.toInt()}: \$${spot.y.toStringAsFixed(0)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),

          // Eje de Fechas (Punto Inicial y Final)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateLabel("Hoy", startDateStr),
                if (daysLeft > 0)
                  _buildDateLabel("Agotamiento", endDateStr, isCritical: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel(String label, String date, {bool isCritical = false}) {
    return Column(
      crossAxisAlignment: isCritical
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isCritical ? Colors.redAccent : Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(date, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildHeader(double days, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Flujo de Caja",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Fin: $date",
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateProjectionSpots() {
    double balance = engine.transactions.fold(
      0.0,
      (s, t) => t.type == TransactionType.income ? s + t.amount : s - t.amount,
    );

    double monthlyBills = engine.bills.fold(0.0, (s, b) => s + b.amount);
    double b = -monthlyBills / 30; // Coeficiente lineal
    double a = -1.5; // Coeficiente cuadrático (aceleración)

    List<FlSpot> points = [];
    // Graficamos de t=0 a t=30 días
    for (int t = 0; t <= 30; t++) {
      // f(t) = at² + bt + c
      double y = (a * t * t) + (b * t) + balance;
      if (y < 0) y = 0; // El dinero no puede ser negativo en la gráfica
      points.add(FlSpot(t.toDouble(), y));
    }
    return points;
  }
}
