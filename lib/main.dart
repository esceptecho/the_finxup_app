// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:the_finxup_app/models/bill.dart';
import 'package:the_finxup_app/models/goal.dart';
import 'package:the_finxup_app/screens/dashboard_screen.dart';
import 'package:the_finxup_app/screens/login_screen.dart';
import 'package:the_finxup_app/screens/main_screen.dart';
import 'package:the_finxup_app/screens/onboardingScreens/onboarding_screen.dart';
import 'package:the_finxup_app/screens/splash_screen_wrapper.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
// import 'package:time_machine/time_machine.dart';

// Importaciones de tus modelos
import 'models/hive_transaction_model.dart';

Future<void> main() async {
  // 1. Asegurar vinculación con el motor de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  // Sets up timezone and culture information
  // await TimeMachine.initialize();

  // 2. Inicialización de Hive e Intl
  await Hive.initFlutter();
  await initializeDateFormatting('es_ES', null);

  // 3. Registro de Adaptadores
  // IMPORTANTE: El orden debe coincidir con los typeId definidos en tus archivos .g.dart
  _registerHiveAdapters();

  // 4. Apertura de Boxes
  await _openHiveBoxes();

  runApp(const ProviderScope(child: MyApp()));
}

void _registerHiveAdapters() {
  // Usamos el check isAdapterRegistered para evitar errores en Hot Reload

  // TypeId: 0 - TransactionType (Enum)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }

  // TypeId: 1 - IncomeSubCategory (Enum)
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(IncomeSubCategoryAdapter());
  }

  // TypeId: 2 - ExpenseSubCategory (Enum)
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ExpenseSubCategoryAdapter());
  }

  // TypeId: 3 - Transaction (Clase principal)
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(TransactionAdapter());
  }

  // Adaptadores para Bill y Goal (Asegúrate de que sus typeId no choquen con 0,1,2,3)
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(BillAdapter());
  }

  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(GoalAdapter());
  }
}

Future<void> _openHiveBoxes() async {
  // Abrimos las cajas especificando el tipo para que Riverpod las encuentre fácil
  await Future.wait([
    Hive.openBox<Transaction>('transactions'),
    Hive.openBox<Bill>('bills'),
    Hive.openBox<Goal>('goals'),
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finxup App',
      debugShowCheckedModeBanner: false,

      // --- TEMA CLARO ---
      // Usamos los colores de marca de tu clase AppThemeHSL
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppThemeHSL.primary,
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppThemeHSL.primary,
          primary: AppThemeHSL.primary,
          secondary: AppThemeHSL.accentGold,
          // Para el fondo claro, usamos el blanco estándar de Material
          // ya que tu clase define fondos específicos para Dark Mode.
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppThemeHSL.primary,
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Aquí defines la estética global de todos los inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppThemeHSL.surface.withValues(alpha: 0.3),
          labelStyle: TextStyle(color: AppThemeHSL.textMuted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Sin borde por defecto
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppThemeHSL.surface.withValues(alpha: 0.1),
              width: 0,
            ),
          ),
          // Podemos poner un color de foco genérico aquí
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
      ),

      // --- TEMA OSCURO ---
      // Llamamos directamente a tu getter especializado
      darkTheme: AppThemeHSL.darkTheme,

      themeMode: ThemeMode.system,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenWrapper(),
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/analytics': (context) => const DashboardScreen(),
        '/home': (context) => const MainScreen(), 
        // '/mainHome': (context) => const EnhancedHomeScreen(), 
      },
    );
  }
}


