// import 'dart:math';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:the_finxup_app/models/bill.dart';
// import 'package:the_finxup_app/models/goal.dart';
// import 'package:the_finxup_app/models/hive_transaction_model.dart';
// import 'package:the_finxup_app/providers/transaction_notifiers.dart';
// import 'package:the_finxup_app/repositories/hive_repository.dart';

// // Este provider combina los 3 AsyncNotifiers en un solo objeto de lógica
// final financeLogicProvider = Provider<AsyncValue<FinanceAnalyticsEngine>>((
//   ref,
// ) {
//   final txsAsync = ref.watch(transactionListNotifierProvider);
//   final billsAsync = ref.watch(billListNotifierProvider);
//   final goalsAsync = ref.watch(goalListNotifierProvider);

//   // Solo creamos el motor si los 3 ya tienen datos (AsyncData)
//   if (txsAsync is AsyncData &&
//       billsAsync is AsyncData &&
//       goalsAsync is AsyncData) {
//     return AsyncValue.data(
//       FinanceAnalyticsEngine(
//         transactions: txsAsync.value!,
//         bills: billsAsync.value!,
//         goals: goalsAsync.value!,
//       ),
//     );
//   }

//   // Si alguno está cargando, el motor completo está cargando
//   return const AsyncValue.loading();
// });


// // Asegúrate de importar tus modelos aquí (Transaction, Bill, Goal, etc.)

// class FinanceAnalyticsEngine {
//   final List<Transaction> transactions;
//   final List<Bill> bills;
//   final List<Goal> goals;

//   FinanceAnalyticsEngine({
//     required this.transactions,
//     required this.bills,
//     required this.goals,
//   });

//   // --- EJERCICIO 1: Evaluación de Funciones (Salud Financiera) ---
//   // Fórmula: H(x) = 3(Ahorros + Inversiones) - 4(Gastos Impulsivos + Intereses)
//   double getFinancialHealthIndex() {
//     double positiveHabits = transactions.where((t) => 
//       t.subCategory == ExpenseSubCategory.savings || 
//       t.subCategory == IncomeSubCategory.investment
//     ).fold(0.0, (sum, t) => sum + t.amount);

//     double negativeHabits = transactions.where((t) => 
//       t.subCategory == ExpenseSubCategory.impulsive || 
//       t.subCategory == ExpenseSubCategory.interest
//     ).fold(0.0, (sum, t) => sum + t.amount);
    
//     return (3 * positiveHabits) - (4 * negativeHabits);
//   }

//   // --- EJERCICIO 2: Funciones a Trozos (Nivel de Estilo de Vida) ---
//   String getLifestyleLevel() {
//     double funSpend = transactions.where((t) => 
//       t.type == TransactionType.expense && 
//       (t.subCategory == ExpenseSubCategory.leisure || t.subCategory == ExpenseSubCategory.entertainment)
//     ).fold(0.0, (sum, t) => sum + t.amount);

//     // Definición de la función por partes:
//     if (funSpend <= 100) return "Ahorrador Estricto";
//     if (funSpend <= 300) return "Equilibrado";
//     return "Vividor (Riesgo)";
//   }

//   // --- EJERCICIO 6: Intervalos de Crecimiento (Tendencia en Comida) ---
//   String getFoodSpendingTrend() {
//     final now = DateTime.now();
    
//     double thisMonthFood = transactions.where((t) => 
//       t.subCategory == ExpenseSubCategory.food && t.date.month == now.month
//     ).fold(0.0, (sum, t) => sum + t.amount);

//     double lastMonthFood = transactions.where((t) => 
//       t.subCategory == ExpenseSubCategory.food && t.date.month == now.month - 1
//     ).fold(0.0, (sum, t) => sum + t.amount);

//     if (thisMonthFood > lastMonthFood) return "Creciente 📈";
//     if (thisMonthFood < lastMonthFood) return "Decreciente 📉";
//     return "Estable ➖";
//   }

//   // --- EJERCICIO 7: Ecuación Cuadrática (Días de Liquidez) ---
//   // Modificado para incluir el gasto fijo de los "Bills" (Facturas)
//   double predictDaysOfLiquidity() {
//     double balance = transactions.fold(0.0, (s, t) => 
//       t.type == TransactionType.income ? s + t.amount : s - t.amount);
    
//     // Gasto lineal fijo (Facturas recurrentes)
//     double monthlyBills = bills.fold(0.0, (s, b) => s + b.amount);
//     double b = -monthlyBills / 30; // Gasto diario base
    
//     double a = -1.5; // Aceleración de gasto (Parábola hacia abajo)

//     double discriminant = pow(b, 2) - (4 * a * balance);
//     if (discriminant < 0 || balance <= 0) return 0;
    
//     return (-b - sqrt(discriminant)) / (2 * a);
//   }

//   // --- EJERCICIO 9: Desigualdades (Viabilidad de Metas) ---
//   List<String> checkGoalsViability() {
//     List<String> alerts = [];
//     // Ejemplo de inecuación: Ahorro_Mensual * tiempo < Meta
//     // Lógica simplificada para el ejemplo
//     for (var goal in goals) {
//       if (goal.currentAmount < (goal.targetAmount * 0.2)) {
//         alerts.add("Tu meta '${goal.title}' está en zona crítica.");
//       }
//     }
//     return alerts;
//   }
// }
