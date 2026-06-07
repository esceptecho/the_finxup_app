import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

enum ChartPeriod { week, month, quarter, year }

class DsStatisticsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const DsStatisticsScreen({super.key, required this.transactions});

  @override
  State<DsStatisticsScreen> createState() => _DsStatisticsScreenState();
}

class _DsStatisticsScreenState extends State<DsStatisticsScreen> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;
  bool _isLoading = false;

  double _totalSpent = 0.0;
  double _previousTotalSpent = 0.0; // para calcular tendencia
  double _maxExpense = 0.0;
  List<FlSpot> _chartSpots = [];
  final Map<ChartPeriod, List<FlSpot>> _spotsCache = {};

  @override
  void initState() {
    super.initState();
    _processData();
  }

  Future<void> _processData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Pequeño delay para que la animación se note (opcional)
    await Future.delayed(const Duration(milliseconds: 10));

    final now = DateTime.now();
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

    // Fechas del período actual
    final startDate = _selectedPeriod == ChartPeriod.year
        ? DateTime(now.year, now.month - 11, 1)
        : now.subtract(Duration(days: pointsCount - 1));

    // Fechas del período anterior (para la tendencia)
    final previousStartDate = _selectedPeriod == ChartPeriod.year
        ? DateTime(now.year - 1, now.month - 11, 1)
        : startDate.subtract(Duration(days: pointsCount));
    final previousEndDate = startDate.subtract(const Duration(days: 1));

    double tempTotal = 0.0;
    double tempPrevTotal = 0.0;
    double tempMax = 0.0;
    final Map<String, double> dataMap = {};
    final Map<String, double> prevDataMap = {};

    for (var tx in widget.transactions) {
      if (tx.type != TransactionType.expense) continue;

      final key = DateFormat(dateFormat).format(tx.date);
      if (tx.date.isAfter(startDate) || tx.date.isAtSameMomentAs(startDate)) {
        dataMap.update(key, (v) => v + tx.amount, ifAbsent: () => tx.amount);
        tempTotal += tx.amount;
        if (tx.amount > tempMax) tempMax = tx.amount;
      } else if (tx.date.isAfter(previousStartDate) &&
          tx.date.isBefore(previousEndDate)) {
        prevDataMap.update(
          key,
          (v) => v + tx.amount,
          ifAbsent: () => tx.amount,
        );
        tempPrevTotal += tx.amount;
      }
    }

    // Generar los spots para el gráfico
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

    // Guardar en caché por período
    _spotsCache[_selectedPeriod] = spots;

    setState(() {
      _chartSpots = spots;
      _totalSpent = tempTotal;
      _previousTotalSpent = tempPrevTotal;
      _maxExpense = tempMax;
      _isLoading = false;
    });
  }

  /// Cambia el período con animación de fade en el gráfico
  void _changePeriod(ChartPeriod newPeriod) {
    if (_selectedPeriod == newPeriod) return;
    setState(() {
      _selectedPeriod = newPeriod;
      _chartSpots = []; // limpia para mostrar el fade
    });
    _processData(); // recalcula y llena _chartSpots de nuevo
  }

  double get _dailyAverage =>
      _totalSpent /
      (_selectedPeriod == ChartPeriod.week
          ? 7
          : _selectedPeriod == ChartPeriod.month
          ? 30
          : _selectedPeriod == ChartPeriod.quarter
          ? 90
          : 365);

  String get _trendText {
    if (_previousTotalSpent == 0) return "vs período anterior";
    final percent =
        ((_totalSpent - _previousTotalSpent) / _previousTotalSpent) * 100;
    if (percent.abs() < 0.01) return "vs período anterior";
    final arrow = percent > 0 ? "▲" : "▼";
    return "$arrow ${percent.toStringAsFixed(1)}% vs período anterior";
  }

  Color get _trendColor =>
      _totalSpent > _previousTotalSpent ? Colors.redAccent : Colors.greenAccent;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final compactFormatter = NumberFormat.compactCurrency(
      symbol: '\$',
      decimalDigits: 1,
    );

    return Scaffold(
      backgroundColor: AppThemeHSL.backgroundDeep,
      appBar: AppBar(
        title: const Text(
          'Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            

            // ---------- Cabecera con total y tendencia ----------
            Column(
              children: [
                Text(
                  'Total Gastado',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormatter.format(_totalSpent),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                // Indicador de tendencia (aprovecha espacio)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _trendColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    _trendText,
                    style: TextStyle(
                      color: _trendColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ---------- Gráfico rediseñado (más fino, con puntos y transición suave) ----------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 340,
              decoration: BoxDecoration(
                color: AppThemeHSL.backgroundDeep, // const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 36),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppThemeHSL.accentGold,
                            ),
                          )
                        : LineChart(
                            key: ValueKey(
                              _selectedPeriod,
                            ), // fuerza rebuild al cambiar período
                            _buildLineChartData(
                              compactFormatter,
                              currencyFormatter,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // const SizedBox(height: 8),
// ---------- Selector de período personalizado (más fino) ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPeriodSelector(),
            ),

            const SizedBox(height: 24),
            // ---------- Tarjetas resumen (más compactas pero informativas) ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.trending_up_rounded,
                      title: 'Gasto más alto',
                      value: currencyFormatter.format(_maxExpense),
                      color: const Color(0xFFFF1744),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.calendar_today,
                      title: 'Promedio diario',
                      value: currencyFormatter.format(_dailyAverage),
                      color: AppThemeHSL.accentGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ------------------------ UI COMPONENTES ------------------------

  Widget _buildPeriodSelector() {
    final periods = [
      ChartPeriod.week,
      ChartPeriod.month,
      ChartPeriod.quarter,
      ChartPeriod.year,
    ];
    final labels = ['7D', '30D', '3M', '1A'];

    return Container(
      decoration: BoxDecoration(
        color: AppThemeHSL.background.withValues(
          alpha: 0.08,
        ), // const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(periods.length, (index) {
          final period = periods[index];
          final isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () => _changePeriod(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemeHSL.accentGold.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: isSelected
                      ? AppThemeHSL.accentGold
                      : Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: isSelected
                      ? AppThemeHSL.accentGold
                      : Colors.blueGrey.shade300,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppThemeHSL.background,// const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------ GRÁFICO FINO ------------------------
  LineChartData _buildLineChartData(
    NumberFormat compactFormatter,
    NumberFormat currencyFormatter,
  ) {
    return LineChartData(
      gridData: FlGridData(
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.white.withValues(alpha: 0.2),
          strokeWidth: 0.1,

        ),
        verticalInterval: 2.0,
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _getYInterval(),
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withValues(alpha: 0.2),
          strokeWidth: 0.2,
          // dashArray: [5, 5,],

        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: _getYInterval(),
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8,),
                child: Text(
                  compactFormatter.format(value),
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            interval: _getXInterval(),
            getTitlesWidget: (value, meta) => _buildBottomLabels(value),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => const Color(0xFF252545),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              // Obtener la fecha correspondiente para mostrarla en el tooltip
              String dateLabel = "";
              try {
                final int idx = spot.spotIndex.toInt();
                final now = DateTime.now();
                if (_selectedPeriod == ChartPeriod.year) {
                  final date = DateTime(now.year, now.month - (11 - idx), 1);
                  dateLabel = DateFormat('MMM yyyy', 'es_ES').format(date);
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
                  final date = now.subtract(
                    Duration(days: daysToSubtract - idx),
                  );
                  dateLabel = DateFormat('dd MMM', 'es_ES').format(date);
                }
              } catch (_) {}
              return LineTooltipItem(
                "${currencyFormatter.format(spot.y)}\n$dateLabel",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              );
            }).toList();
          },
        ),
        touchSpotThreshold: 8,
        getTouchLineStart: (data, index) => 0,
        getTouchLineEnd: (data, index) => double.infinity,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _chartSpots.isEmpty ? [const FlSpot(0, 0)] : _chartSpots,
          isCurved: true,
          curveSmoothness: 0.9,
          gradient: LinearGradient(
            colors: [AppThemeHSL.accentGoldSoft, AppThemeHSL.surfaceLighter],
          ),
          barWidth: 1.0,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 0.2,
                  color: Colors.white38,
                  strokeWidth: 0.5,
                  strokeColor: AppThemeHSL.accentGold,
                ),
          ),
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
      minY: 0,
      maxY: _chartSpots.isEmpty
          ? 1
          : _chartSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.05,
    );
  }

  double _getYInterval() {
    if (_chartSpots.isEmpty) return 100;
    final maxVal = _chartSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    if (maxVal < 100) return 20;
    if (maxVal < 500) return 100;
    return 200;
  }

  double _getXInterval() {
    final int totalPoints;
    switch (_selectedPeriod) {
      case ChartPeriod.week:
        totalPoints = 7;
        break;
      case ChartPeriod.month:
        totalPoints = 30;
        break;
      case ChartPeriod.quarter:
        totalPoints = 90;
        break;
      case ChartPeriod.year:
        totalPoints = 12;
        break;
    }

    // ✅ Mostrar máximo 6-7 etiquetas para evitar sobreposición
    final maxLabels = 6.0;
    return (totalPoints / maxLabels).ceil().toDouble();
  }

  Widget _buildBottomLabels(double value) {
    if (_chartSpots.isEmpty) return const SizedBox.shrink();
    final int idx = value.toInt();
    if (idx < 0 ||
        idx >=
            (_selectedPeriod == ChartPeriod.year
                ? 12
                : (_selectedPeriod == ChartPeriod.week
                      ? 7
                      : (_selectedPeriod == ChartPeriod.month ? 30 : 90)))) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    String text = "";
    try {
      if (_selectedPeriod == ChartPeriod.year) {
        final date = DateTime(now.year, now.month - (11 - idx), 1);
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
        final date = now.subtract(Duration(days: daysToSubtract - idx));
        text = _selectedPeriod == ChartPeriod.week
            ? DateFormat('E', 'es_ES').format(date)
            : DateFormat('dd MMM', 'es_ES').format(date);
      }
    } catch (_) {}
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Transform.translate(
        offset: const Offset(0, 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.blueGrey.shade400,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
