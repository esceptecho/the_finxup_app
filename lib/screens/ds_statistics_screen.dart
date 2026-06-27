import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/financial_summary_provider.dart';
import 'package:the_finxup_app/providers/transaction_notifiers.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

enum ChartPeriod { week, month, quarter, year }

class DsStatisticsScreen extends ConsumerStatefulWidget {
  const DsStatisticsScreen({super.key});

  @override
  ConsumerState<DsStatisticsScreen> createState() => _DsStatisticsScreenState();
}

class _DsStatisticsScreenState extends ConsumerState<DsStatisticsScreen> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;
  bool _isLoading = false;

  double _previousTotalSpent = 0.0;
  double _maxExpense = 0.0;
  List<FlSpot> _chartSpots = [];
  final Map<ChartPeriod, List<FlSpot>> _spotsCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(transactionListNotifierProvider, (prev, next) {
      if (prev != next) {
        _processData();
      }
    });
  }

  Future<void> _processData() async {
    if (_isLoading) return;

    final transactionsAsync = ref.read(transactionListNotifierProvider);

    if (transactionsAsync is! AsyncData) {
      setState(() => _isLoading = false);
      return;
    }

    final transactions = transactionsAsync.value;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 10));

    if (!mounted) return;

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

    final startDate = _selectedPeriod == ChartPeriod.year
        ? DateTime(now.year, now.month - 11, 1)
        : now.subtract(Duration(days: pointsCount - 1));

    final previousStartDate = _selectedPeriod == ChartPeriod.year
        ? DateTime(now.year - 1, now.month - 11, 1)
        : startDate.subtract(Duration(days: pointsCount));
    final previousEndDate = startDate.subtract(const Duration(days: 1));

    double tempPrevTotal = 0.0;
    double tempMax = 0.0;
    final Map<String, double> dataMap = {};
    final Map<String, double> prevDataMap = {};

    for (var tx in transactions!) {
      if (tx.type != TransactionType.expense) continue;

      final key = DateFormat(dateFormat).format(tx.date);

      if (tx.date.isAfter(startDate) || tx.date.isAtSameMomentAs(startDate)) {
        dataMap.update(key, (v) => v + tx.amount, ifAbsent: () => tx.amount);
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

    _spotsCache[_selectedPeriod] = spots;

    if (!mounted) return;

    setState(() {
      _chartSpots = spots;
      _previousTotalSpent = tempPrevTotal;
      _maxExpense = tempMax;
      _isLoading = false;
    });
  }

  void _changePeriod(ChartPeriod newPeriod) {
    if (_selectedPeriod == newPeriod) return;
    setState(() {
      _selectedPeriod = newPeriod;
      _chartSpots = [];
    });
    _processData();
  }

  double get _totalSpent {
    final summary = ref.watch(financialSummaryProvider);
    return summary.expense;
  }

  double get _dailyAverage {
    final daysInPeriod = _selectedPeriod == ChartPeriod.week
        ? 7
        : _selectedPeriod == ChartPeriod.month
        ? 30
        : _selectedPeriod == ChartPeriod.quarter
        ? 90
        : 365;

    return daysInPeriod > 0 ? _totalSpent / daysInPeriod : 0.0;
  }

  String get _trendText {
    if (_previousTotalSpent == 0) return "vs período anterior";
    final percent =
        ((_totalSpent - _previousTotalSpent) / _previousTotalSpent) * 100;
    if (percent.abs() < 0.01) return "vs período anterior";
    final arrow = percent > 0 ? "▲" : "▼";
    return "$arrow ${percent.toStringAsFixed(1)}% vs período anterior";
  }

  Color get _trendColor {
    if (_previousTotalSpent == 0) return Colors.grey;
    return _totalSpent > _previousTotalSpent
        ? Colors.redAccent
        : Colors.greenAccent;
  }

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
      body: RefreshIndicator(
        color: AppThemeHSL.accentGold,
        onRefresh: () async {
          ref.invalidate(transactionListNotifierProvider);
          _processData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // ---------- Cabecera con total y tendencia ----------
              _buildHeader(currencyFormatter),

              const SizedBox(height: 24),

              // ---------- Gráfico ----------
              _buildChartSection(compactFormatter, currencyFormatter),

              const SizedBox(height: 8),

              // ---------- Selector de período ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPeriodSelector(),
              ),

              const SizedBox(height: 24),

              // ---------- Tarjetas resumen ----------
              _buildSummaryCards(currencyFormatter),

              // ---------- Espacio adicional para scroll ----------
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }

  // ======================= WIDGETS DE UI =======================

  Widget _buildHeader(NumberFormat currencyFormatter) {
    return Column(
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            currencyFormatter.format(_totalSpent),
            key: ValueKey(_totalSpent),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 46,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    );
  }

  Widget _buildChartSection(
    NumberFormat compactFormatter,
    NumberFormat currencyFormatter,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 360, // ✅ Aumentado para mejor espaciado
      decoration: BoxDecoration(
        color: AppThemeHSL.backgroundDeep,
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
          padding: const EdgeInsets.fromLTRB(8, 20, 16, 40),
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
                    key: ValueKey(_selectedPeriod),
                    _buildLineChartData(compactFormatter, currencyFormatter),
                  ),
          ),
        ),
      ),
    );
  }

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
        color: AppThemeHSL.background.withValues(alpha: 0.08),
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

  Widget _buildSummaryCards(NumberFormat currencyFormatter) {
    return Padding(
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
        color: AppThemeHSL.background,
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

  // ======================= CONFIGURACIÓN DEL GRÁFICO =======================

  LineChartData _buildLineChartData(
    NumberFormat compactFormatter,
    NumberFormat currencyFormatter,
  ) {
    final maxY = _chartSpots.isEmpty
        ? 100.0
        : _chartSpots
                  .map((e) => e.y)
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() *
              1.1; // ← Convertir antes de multiplicar

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateNiceInterval(maxY),
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withValues(alpha: 0.08),
          strokeWidth: 0.5,
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
            reservedSize: 56, // ✅ Más espacio para labels
            interval: _calculateNiceInterval(maxY),
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Text(
                  compactFormatter.format(value),
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: _getXInterval(),
            getTitlesWidget: (value, meta) => _buildBottomLabels(value),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              const Color(0xFF252545).withValues(alpha: 0.95),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipBorderRadius: BorderRadius.circular(8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              String dateLabel = _getTooltipDateLabel(spot.spotIndex);
              return LineTooltipItem(
                '${currencyFormatter.format(spot.y)}\n$dateLabel',
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
        touchSpotThreshold: 12,
        getTouchLineStart: (data, index) => 0,
        getTouchLineEnd: (data, index) => double.infinity,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _chartSpots.isEmpty ? [const FlSpot(0, 0)] : _chartSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: LinearGradient(
            colors: [AppThemeHSL.accentGoldSoft, AppThemeHSL.surfaceLighter],
          ),
          barWidth: 2.0,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppThemeHSL.accentGold.withValues(alpha: 0.25),
                AppThemeHSL.accentGold.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      minY: 0,
      maxY: maxY,
    );
  }

  /// Calcula un intervalo "bonito" para el eje Y
  double _calculateNiceInterval(double maxValue) {
    if (maxValue <= 0) return 50;

    // Encontrar la magnitud
    final magnitude = _pow10((maxValue).toStringAsFixed(0).length - 1);
    final residual = maxValue / magnitude;

    final niceTick;
    if (residual <= 1.5) {
      niceTick = magnitude / 5;
    } else if (residual <= 3) {
      niceTick = magnitude / 2;
    } else if (residual <= 7) {
      niceTick = magnitude;
    } else {
      niceTick = magnitude * 2;
    }

    // Asegurar al menos 3 líneas y máximo 6
    return niceTick.clamp(maxValue / 6, maxValue / 2);
  }

  double _pow10(int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
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

    // Máximo 6 etiquetas para evitar sobreposición
    final maxLabels = 6.0;
    return (totalPoints / maxLabels).ceilToDouble();
  }

  String _getTooltipDateLabel(int idx) {
    try {
      final now = DateTime.now();
      if (_selectedPeriod == ChartPeriod.year) {
        final date = DateTime(now.year, now.month - (11 - idx), 1);
        return DateFormat('MMM yyyy', 'es_ES').format(date);
      } else {
        int daysToSubtract = _getDaysToSubtract();
        final date = now.subtract(Duration(days: daysToSubtract - idx));
        return DateFormat('dd MMM', 'es_ES').format(date);
      }
    } catch (_) {
      return '';
    }
  }

  int _getDaysToSubtract() {
    switch (_selectedPeriod) {
      case ChartPeriod.week:
        return 6;
      case ChartPeriod.month:
        return 29;
      case ChartPeriod.quarter:
        return 89;
      default:
        return 6;
    }
  }

  Widget _buildBottomLabels(double value) {
    if (_chartSpots.isEmpty) return const SizedBox.shrink();

    final int idx = value.toInt();
    final int maxIndex = _selectedPeriod == ChartPeriod.year
        ? 12
        : _selectedPeriod == ChartPeriod.week
        ? 7
        : _selectedPeriod == ChartPeriod.month
        ? 30
        : 90;

    if (idx < 0 || idx >= maxIndex) return const SizedBox.shrink();

    final now = DateTime.now();
    String text = '';
    bool isMainLabel = false;

    try {
      if (_selectedPeriod == ChartPeriod.year) {
        final date = DateTime(now.year, now.month - (11 - idx), 1);
        text = DateFormat.MMM('es_ES').format(date).toUpperCase();
        isMainLabel = true;
      } else {
        int daysToSubtract = _getDaysToSubtract();
        final date = now.subtract(Duration(days: daysToSubtract - idx));

        if (_selectedPeriod == ChartPeriod.week) {
          text = DateFormat('E', 'es_ES').format(date).substring(0, 2);
          isMainLabel = true;
        } else {
          // Para mes y trimestre, mostrar solo algunos labels
          if (idx % _getXInterval().toInt() == 0) {
            text = DateFormat('dd MMM', 'es_ES').format(date);
            isMainLabel = true;
          }
        }
      }
    } catch (_) {}

    if (!isMainLabel) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blueGrey.shade400,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
