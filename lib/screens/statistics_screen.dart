import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/screens/transaction_history_view.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

enum ChartPeriod { week, month, quarter, year }

class StatisticsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  double _totalSpent = 0.0;
  double _maxExpense = 0.0;
  List<FlSpot> _chartSpots = [];

  @override
  void initState() {
    super.initState();
    _processData();
  }

  void _processData() {
    final Map<String, double> dataMap = {};
    DateTime now = DateTime.now();
    int pointsCount;
    String dateFormat;

    switch (_selectedPeriod) {
      case ChartPeriod.week:
        pointsCount = 7;
        dateFormat = 'yyyy-MM-dd';
        break;
      case ChartPeriod.month:
        pointsCount = 30;
        dateFormat = 'yyyy-MM-dd';
        break;
      case ChartPeriod.quarter:
        pointsCount = 90;
        dateFormat = 'yyyy-MM-dd';
        break;
      case ChartPeriod.year:
        pointsCount = 12;
        dateFormat = 'yyyy-MM';
        break;
    }

    DateTime startDate = _selectedPeriod == ChartPeriod.year
        ? DateTime(now.year, now.month - 11, 1)
        : now.subtract(Duration(days: pointsCount - 1));

    double tempTotal = 0.0;
    double tempMax = 0.0;

    for (var tx in widget.transactions) {
      if (tx.type == TransactionType.expense && tx.date.isAfter(startDate)) {
        final key = DateFormat(dateFormat).format(tx.date);

        dataMap.update(key, (v) => v + tx.amount, ifAbsent: () => tx.amount);
        tempTotal += tx.amount;

        if (tx.amount > tempMax) {
          tempMax = tx.amount;
        }
      }
    }

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

    setState(() {
      _chartSpots = spots;
      _totalSpent = tempTotal;
      _maxExpense = tempMax;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor:
          AppThemeHSL.backgroundDeep, // Sincronizado con el Dashboard
      appBar: AppBar(
        title: const Text(
          'Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // 1. Selector de Periodo (Modernizado para Dark Mode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SegmentedButton<ChartPeriod>(
                segments: const [
                  ButtonSegment(value: ChartPeriod.week, label: Text("7D")),
                  ButtonSegment(value: ChartPeriod.month, label: Text("30D")),
                  ButtonSegment(value: ChartPeriod.quarter, label: Text("3M")),
                  ButtonSegment(value: ChartPeriod.year, label: Text("1A")),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedPeriod = newSelection.first;
                    _processData();
                  });
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF1A1A2E,
                  ).withValues(alpha: 0.5),
                  selectedBackgroundColor: AppThemeHSL.accentGold.withValues(
                    alpha: 0.2,
                  ),
                  selectedForegroundColor: AppThemeHSL.accentGold,
                  foregroundColor: Colors.blueGrey.shade400,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. Cabecera de Total Gastado
            Column(
              children: [
                Text(
                  'Total Gastado',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(_totalSpent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 3. Tarjeta del Gráfico (Estilo Dark Mode Hero)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 24),
              height: 260,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF1A1A2E,
                ), // Mismo contenedor oscuro del Dashboard
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _getInterval(),
                        getTitlesWidget: (value, meta) =>
                            _buildBottomLabels(value),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => const Color(0xFF252545),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            currencyFormatter.format(spot.y),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartSpots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      // Gradiente cálido para los gastos
                      gradient: LinearGradient(
                        colors: [
                          AppThemeHSL.accentGold,
                          const Color(0xFFFF512F),
                        ],
                      ),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppThemeHSL.accentGold.withValues(alpha: 0.2),
                            const Color(0xFFFF512F).withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Tarjetas de Resumen Adicionales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.trending_up_rounded,
                      title: 'Gasto Más Alto',
                      value: currencyFormatter.format(_maxExpense),
                      color: const Color(0xFFFF1744), // Rojo Neón
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.analytics_outlined,
                      title: 'Promedio Diario',
                      value: currencyFormatter.format(_getDailyAverage()),
                      color: AppThemeHSL.accentGold, // Dorado
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

  // --- Helpers UI y Lógica ---

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1A1A2E,
        ), // Sincronizado con las tarjetas del Dashboard
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: .start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getInterval() {
    switch (_selectedPeriod) {
      case ChartPeriod.week:
        return 1;
      case ChartPeriod.month:
        return 6;
      case ChartPeriod.quarter:
        return 15;
      case ChartPeriod.year:
        return 2;
    }
  }

  double _getDailyAverage() {
    if (_totalSpent == 0) return 0.0;
    int days = _selectedPeriod == ChartPeriod.week
        ? 7
        : (_selectedPeriod == ChartPeriod.month
              ? 30
              : (_selectedPeriod == ChartPeriod.quarter ? 90 : 365));
    return _totalSpent / days;
  }

  Widget _buildBottomLabels(double value) {
    String text = "";
    DateTime now = DateTime.now();

    try {
      if (_selectedPeriod == ChartPeriod.year) {
        DateTime date = DateTime(now.year, now.month - (11 - value.toInt()), 1);
        text = DateFormat.MMM('es_ES').format(date).toUpperCase();
      } else {
        int daysToSubtract;
        switch (_selectedPeriod) {
          case ChartPeriod.week:
            daysToSubtract = 6;
            break;
          case ChartPeriod.month:
            daysToSubtract = 29;
            break;
          case ChartPeriod.quarter:
            daysToSubtract = 89;
            break;
          default:
            daysToSubtract = 6;
        }
        DateTime date = now.subtract(
          Duration(days: daysToSubtract - value.toInt()),
        );
        text = DateFormat('dd MMM', 'es_ES').format(date);
      }
    } catch (e) {
      text = '';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blueGrey.shade400, // Color suavizado para el eje X
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
