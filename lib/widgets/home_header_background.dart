// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:just_tooltip/just_tooltip.dart';
import 'package:the_finxup_app/models/hive_transaction_model.dart';
import 'package:the_finxup_app/providers/financial_summary_provider.dart';
import 'package:the_finxup_app/screens/statistics_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/balance_legend.dart';
import 'package:the_finxup_app/widgets/icon_stat_ring.dart';
import 'package:the_finxup_app/widgets/movimientos.dart';
import 'package:the_finxup_app/widgets/shimmer_border_wrapper.dart';

class HomeHeaderBackground extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;
  final double spentPercentage;
  final List<Transaction> transactions;

  const HomeHeaderBackground({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.spentPercentage,
    required this.transactions,
  });

  @override
  State<HomeHeaderBackground> createState() => _HomeHeaderBackgroundState();
}

class _HomeHeaderBackgroundState extends State<HomeHeaderBackground> {
  final JustTooltipController _controller = JustTooltipController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            AppThemeHSL.divider,
            BlendMode.hardLight,
          ),
          image: const AssetImage('assets/fondo_degradado_login.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(7),
          bottomRight: Radius.circular(7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemeHSL.accentGoldSoft.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Columna Izquierda: Balances Financieros
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Balance Total',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppThemeHSL.textSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: JustTooltip(
                        controller: _controller,
                         enableTap: true, // ✅ Se dispara con clic/tap
                        enableHover: true, // ✅ Se dispara con hover (mouse)
                         // ✅ En su lugar, usa el theme con arrowOptions
                        theme: JustTooltipTheme(
                          showArrow:
                              true, // ✅ ¡Así se activa la flecha en tu versión!
                          arrowBaseWidth: 12.0, // Ancho de la base de la flecha
                          arrowLength: 6.0, // Largo de la flecha
                          arrowPositionRatio:
                              0.25, // Posición de la flecha (0.0 = inicio, 0.5 = centro)
                          backgroundColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          padding: EdgeInsets.all(12),
                          elevation: 4.0,
                        ),
                        tooltipBuilder: (context) {
                          return Container(
                            margin: EdgeInsets.all(24),
                            child: Card( 
                              color: AppThemeHSL.surfaceLighter,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Editar'),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          CurrencyFormatter.formatAmount(
                            widget.balance,
                          ), // Uso del Formateador óptimo
                          style: TextStyle(
                            color: widget.balance > 0
                                ? AppThemeHSL.incomeLight
                                : AppThemeHSL.expenseLight,
                            // AppThemeHSL.textPrimary.withValues( alpha: .8),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShimmerBorderWrapper(
                    strokeWidth: 0.5,
                    isAnimating: true,
                    repeat: false,
                    shimmerColor: Colors.transparent,
                    // balance > 0
                    //     ? AppThemeHSL.incomeLight
                    //     : AppThemeHSL.expenseLight,
                    child: Movimientos(),
                  ),
                ],
              ),
            ),

            // Columna Derecha: Anillo Interactivo (Stats)
            Expanded(
              child: Hero(
                tag: 'IconStatRing',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Hero(
                            tag: 'IconStatRing',
                            child: StatisticsScreen(transactions: widget.transactions),
                          ),
                        ),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ShimmerBorderWrapper(
                        strokeWidth: 0.2,
                        isAnimating: true,
                        repeat: false,
                        shimmerColor: Colors.transparent,
                        // balance > 0
                        //     ? AppThemeHSL.incomeLight
                        //     : AppThemeHSL.expenseLight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: IconStatRing(
                                totalBalance: widget.balance,
                                percentage: widget.spentPercentage,
                                iconData: Icons.bar_chart,
                                iconColor: AppThemeHSL.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const BalanceLegend(),
                            // TextButton.icon(
                            //   label: Text(
                            //     'Ver Stats',
                            //     style: TextStyle(
                            //       color: AppThemeHSL.textSecondary,
                            //     ),
                            //   ),
                            //   icon: Icon(
                            //     Icons.ads_click,
                            //     color: AppThemeHSL.textSecondary,
                            //     size: 22,
                            //   ),
                            //   onPressed: () {},
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
