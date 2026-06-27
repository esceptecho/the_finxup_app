// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/screens/dashboard_screen.dart';
import 'package:the_finxup_app/screens/ds_statistics_screen.dart';
import 'package:the_finxup_app/screens/enhanced_home_screen.dart';
import 'package:the_finxup_app/screens/main_transactions_screen.dart';
import 'package:the_finxup_app/screens/transaction_calendar_screen_state.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: const [
          EnhancedHomeScreen(),
          TransactionCalendarScreen(),
          DsStatisticsScreen(), // ✅ Sin parámetros
          DashboardScreen(),
          MainTransactionsScreenV3(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppThemeHSL.background,
        currentIndex: _currentIndex,
        selectedItemColor: AppThemeHSL.primaryExtraLight,
        unselectedItemColor: AppThemeHSL.textMuted,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Análisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            label: 'Presupuesto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows_rounded),
            label: 'Transacciones',
          ),
        ],
      ),
    );
  }
}
