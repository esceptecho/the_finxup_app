import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

enum ChartPeriod { week, month, quarter, year }

class ExpensesChartCard extends StatefulWidget {
  final List<Transaction> transactions;

  const ExpensesChartCard({super.key, required this.transactions});

  @override
  State<ExpensesChartCard> createState() => _ExpensesChartCardState();
}

class _ExpensesChartCardState extends State<ExpensesChartCard> {
  ChartPeriod _selectedPeriod = ChartPeriod.month; // Estado inicial

  // --- Lógica de Procesamiento de Datos ---
  List<FlSpot> _getChartSpots() {
    final Map<String, double> dataMap = {};
    DateTime now = DateTime.now();
    int pointsCount;
    String dateFormat;

    switch (_selectedPeriod) {
      case ChartPeriod.week:
        pointsCount = 7;
        dateFormat = 'yyyy-MM-dd'; // Agrupar por día
        break;
      case ChartPeriod.month:
        pointsCount = 30;
        dateFormat = 'yyyy-MM-dd'; // Agrupar por día
        break;
      case ChartPeriod.quarter:
        pointsCount = 90;
        dateFormat = 'yyyy-MM-dd'; // Agrupar por día
        break;  
      case ChartPeriod.year:
        pointsCount = 12;
        dateFormat = 'yyyy-MM'; // Agrupar por mes
        break;
    }

    // Calcular fecha límite
    DateTime startDate = _selectedPeriod == ChartPeriod.year
        ? DateTime(now.year, now.month - 11, 1)
        : now.subtract(Duration(days: pointsCount - 1));

    // Filtrar y sumar
    for (var tx in widget.transactions) {
      if (tx.type == TransactionType.expense && tx.date.isAfter(startDate)) {
        final key = DateFormat(dateFormat).format(tx.date);
        dataMap.update(key, (v) => v + tx.amount, ifAbsent: () => tx.amount);
      }
    }

    // Convertir a Spots
    List<FlSpot> spots = [];
    for (int i = 0; i < pointsCount; i++) {
      DateTime pointDate;
      if (_selectedPeriod == ChartPeriod.year) {
        pointDate = DateTime(now.year, now.month - (pointsCount - 1 - i), 1);
      } else {
        pointDate = now.subtract(Duration(days: pointsCount - 1 - i));
      }

      final key = DateFormat(dateFormat).format(pointDate);
      spots.add(FlSpot(i.toDouble(), dataMap[key] ?? 0.0));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getChartSpots();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeHSL.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // 1. Selector de Periodo (SegmentedButton)
          SegmentedButton<ChartPeriod>(
            segments: const [
              ButtonSegment(value: ChartPeriod.week, label: Text("7D"), icon: Icon(Icons.calendar_view_week, size: 16)),
              ButtonSegment(value: ChartPeriod.month, label: Text("30D"), icon: Icon(Icons.calendar_view_month, size: 16)),
              ButtonSegment(value: ChartPeriod.quarter, label: Text("3M"), icon: Icon(Icons.calendar_view_month, size: 16)),
              ButtonSegment(value: ChartPeriod.year, label: Text("1Y"), icon: Icon(Icons.calendar_today, size: 16)),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (newSelection) {
              setState(() => _selectedPeriod = newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedBackgroundColor: AppThemeHSL.primary,
              selectedForegroundColor: Colors.white,
              foregroundColor: Colors.white54,
              side: BorderSide.none, // Quitamos el borde para que sea más plano y elegante
            ),
          ),
          
          const SizedBox(height: 25),

          // 2. El Gráfico
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _selectedPeriod == ChartPeriod.month ? 7 : 1, // Espaciado dinámico
                      getTitlesWidget: (value, meta) {
                        return _buildBottomLabels(value);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppThemeHSL.accentGold,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppThemeHSL.accentGold.withOpacity(0.2), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para las etiquetas del eje X
  Widget _buildBottomLabels(double value) {
    String text = "";
    DateTime now = DateTime.now();

    if (_selectedPeriod == ChartPeriod.year) {
      DateTime date = DateTime(now.year, now.month - (11 - value.toInt()), 1);
      text = DateFormat.MMM('es_ES').format(date).toUpperCase();
    } else {
      DateTime date = now.subtract(Duration(days: (_selectedPeriod == ChartPeriod.month ? 29 : 6) - value.toInt()));
      text = DateFormat('dd').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}