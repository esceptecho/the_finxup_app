// import 'package:flutter_riverpod/legacy.dart';
// import 'dart:math';

// import 'package:the_finxup_app/models/hive_transaction_model.dart';
// import 'package:the_finxup_app/models/life_style_profile.dart';
// import 'package:the_finxup_app/providers/transaction_notifiers.dart';

// class FinanceNotifier extends StateNotifier<List<Transaction>> {
//   FinanceNotifier(super.initialState);

//   // --- EJERCICIO 1: Evaluación (Índice de Salud) ---
//   // Fórmula Optimizada: H(x) = 3(Positivos) - 4(Negativos Críticos + Excesos de Ocio)
//   double getFinancialHealthIndex() {
//     // Categorías de GASTO que construyen salud financiera
//     final positiveExpenseCategories = {
//       ExpenseSubCategory.savings,
//       ExpenseSubCategory.education,
//       ExpenseSubCategory.insurance,
//     };

//     // Categorías de INGRESO que representan inversión
//     final positiveIncomeCategories = {IncomeSubCategory.investment};

//     // Categorías que DESTRUYEN salud financiera de forma directa o por descontrol (Gastos Hormiga/Ocio)
//     final negativeExpenseCategories = {
//       ExpenseSubCategory.impulsive,
//       ExpenseSubCategory.interest,
//       ExpenseSubCategory.subscription,
//       ExpenseSubCategory.coffee, // Gasto hormiga añadido
//       ExpenseSubCategory.snacks, // Gasto hormiga añadido
//       ExpenseSubCategory.delivery, // Gasto hormiga añadido
//       ExpenseSubCategory.leisure, // Ocio añadido
//       ExpenseSubCategory.entertainment, // Ocio añadido
//       ExpenseSubCategory.shopping, // Caprichos añadido
//       ExpenseSubCategory.travel, // Viajes añadido
//     };

//     // 1. Cálculo de Hábitos Positivos (Multiplicador x3)
//     double positiveHabits = state
//         .where((t) {
//           if (t.type == TransactionType.expense) {
//             return positiveExpenseCategories.contains(t.subCategory);
//           } else if (t.type == TransactionType.income) {
//             return positiveIncomeCategories.contains(t.subCategory);
//           }
//           return false;
//         })
//         .fold(0.0, (sum, t) => sum + t.amount);

//     // 2. Cálculo de Gastos del Estilo de Vida para evaluar penalizaciones por exceso
//     final lifestyleCategories = {
//       ExpenseSubCategory.leisure,
//       ExpenseSubCategory.entertainment,
//       ExpenseSubCategory.coffee,
//       ExpenseSubCategory.snacks,
//       ExpenseSubCategory.delivery,
//       ExpenseSubCategory.shopping,
//       ExpenseSubCategory.travel,
//     };

//     double totalLifestyleSpend = 0.0;
//     double criticalNegativeSpend = 0.0;

//     for (var t in state) {
//       if (t.type == TransactionType.expense) {
//         // Si pertenece a la bolsa general de hábitos dañinos o de control obligatorio
//         if (negativeExpenseCategories.contains(t.subCategory)) {
//           // Si es específicamente de ocio/hormiga, lo sumamos para medir el exceso por separado
//           if (lifestyleCategories.contains(t.subCategory)) {
//             totalLifestyleSpend += t.amount;
//           } else {
//             // Intereses, impulsivos puros, etc., van directo al castigo sin importar el monto
//             criticalNegativeSpend += t.amount;
//           }
//         }
//       }
//     }

//     // --- LÓGICA DE CASTIGO PROGRESIVO ---
//     // Permitimos hasta $150 de ocio/hormiga bajo un impacto normal.
//     // Todo lo que pase de $150 se considera "Exceso Financiero" y se le aplica un multiplicador de castigo extra.
//     double lifestylePenalty = totalLifestyleSpend;
//     if (totalLifestyleSpend > 150.0) {
//       double excess = totalLifestyleSpend - 150.0;
//       lifestylePenalty +=
//           excess * 1.5; // El excedente castiga un 150% más en la fórmula
//     }

//     double totalNegativeHabits = criticalNegativeSpend + lifestylePenalty;

//     return (3 * positiveHabits) - (4 * totalNegativeHabits);
//   }

//   // --- EJERCICIO 2: Funciones a Trozos (Nivel de Usuario) ---
//   LifestyleProfile getLifestyleLevel() {
//     final lifestyleCategories = {
//       ExpenseSubCategory.leisure,
//       ExpenseSubCategory.entertainment,
//       ExpenseSubCategory.coffee,
//       ExpenseSubCategory.snacks,
//       ExpenseSubCategory.delivery,
//       ExpenseSubCategory.travel,
//       ExpenseSubCategory.shopping,
//     };

//     double funSpend = state
//         .where(
//           (t) =>
//               t.type == TransactionType.expense &&
//               lifestyleCategories.contains(t.subCategory),
//         )
//         .fold(0.0, (sum, t) => sum + t.amount);

//     if (funSpend <= 50) {
//       return LifestyleProfile(
//         name: "Monje Financiero",
//         message: "Tu nivel de gasto en ocio es casi inexistente.",
//         advice:
//             "¡Excelente capacidad de ahorro! Pero recuerda que está bien disfrutar de los frutos de tu trabajo de vez en cuando.",
//         statusColor: "blue",
//       );
//     } else if (funSpend <= 150) {
//       return LifestyleProfile(
//         name: "Ahorrador Consciente",
//         message: "Mantienes tus antojos y salidas bajo un control estricto.",
//         advice:
//             "Estás priorizando tu futuro financiero sin llegar a la privación extrema. Sigue así.",
//         statusColor: "green",
//       );
//     } else if (funSpend <= 350) {
//       return LifestyleProfile(
//         name: "Estilo de Vida Balanceado",
//         message:
//             "Disfrutas de la vida, el café y las salidas de forma moderada.",
//         advice:
//             "Tienes un equilibrio sano. Solo asegúrate de que tu nivel de ahorro mensual sea equivalente o superior a este gasto.",
//         statusColor: "teal",
//       );
//     } else if (funSpend <= 600) {
//       return LifestyleProfile(
//         name: "Explorador del Confort",
//         message:
//             "El delivery, las compras y el entretenimiento están cobrando protagonismo.",
//         advice:
//             "Ojo con los gastos hormiga. Si recortas un 15% en snacks y delivery, tu cuenta de ahorros te lo agradecerá.",
//         statusColor: "orange",
//       );
//     } else {
//       return LifestyleProfile(
//         name: "Vividor (Alerta Roja)",
//         message: "Estás viviendo al límite o dándote una vida de rockstar.",
//         advice:
//             "¡Frena el coche! Estás destinando demasiado capital a la gratificación instantánea. Es urgente revisar tu presupuesto.",
//         statusColor: "red",
//       );
//     }
//   }

//   // --- EJERCICIO 5: Composición f(g(x)) (Gastos Online Extranjeros) ---
//   double calculateForeignOnlineSpend(double usdAmount, double exchangeRate) {
//     double toLocal(double amount) => amount * exchangeRate;
//     double applyBankFee(double amount) => amount * 1.03;

//     return applyBankFee(toLocal(usdAmount));
//   }

//   // --- EJERCICIO 6: Intervalos de Crecimiento (Tendencia de Gasto Alimenticio) ---
//   String getFoodSpendingTrend() {
//     final now = DateTime.now();
//     double thisMonthFood = state
//         .where(
//           (t) =>
//               t.subCategory == ExpenseSubCategory.food &&
//               t.date.month == now.month,
//         )
//         .fold(0.0, (sum, t) => sum + t.amount);

//     double lastMonthFood = state
//         .where(
//           (t) =>
//               t.subCategory == ExpenseSubCategory.food &&
//               t.date.month == now.month - 1,
//         )
//         .fold(0.0, (sum, t) => sum + t.amount);

//     if (thisMonthFood > lastMonthFood) return "Creciente 📈";
//     if (thisMonthFood < lastMonthFood) return "Decreciente 📉";
//     return "Estable ➖";
//   }

//   // --- EJERCICIO 7: Cuadrática (Proyección de Saldo) ---
//   double predictDaysOfLiquidity() {
//     double totalIncome = state
//         .where((t) => t.type == TransactionType.income)
//         .fold(0.0, (s, t) => s + t.amount);
//     double totalExpense = state
//         .where((t) => t.type == TransactionType.expense)
//         .fold(0.0, (s, t) => s + t.amount);

//     double balance = totalIncome - totalExpense;
//     double dailyBurn = -50.0;
//     double acceleration = -1.5;

//     double discriminant = pow(dailyBurn, 2) - (4 * acceleration * balance);
//     if (discriminant < 0 || balance <= 0) return 0;

//     return (-dailyBurn - sqrt(discriminant)) / (2 * acceleration);
//   }

//   // --- EJERCICIO 9: Desigualdades (Límite Seguro) ---
//   bool isSafeSpend(double newExpenseAmount) {
//     double totalIncome = state
//         .where((t) => t.type == TransactionType.income)
//         .fold(0.0, (s, t) => s + t.amount);
//     return newExpenseAmount > 0 && newExpenseAmount <= (totalIncome * 0.5);
//   }

//   /// Gasto mensual promedio de una subcategoría durante los últimos [months] meses.
//   double getAverageMonthlyExpense(
//     ExpenseSubCategory subCategory, {
//     int months = 3,
//   }) {
//     final now = DateTime.now();
//     final cutoffDate = DateTime(now.year, now.month - months + 1, 1);

//     final totalInPeriod = state
//         .where(
//           (t) =>
//               t.type == TransactionType.expense &&
//               t.subCategory == subCategory &&
//               t.date.isAfter(cutoffDate),
//         )
//         .fold(0.0, (sum, t) => sum + t.amount);

//     final monthsWithData = months.clamp(1, 12);
//     return totalInPeriod / monthsWithData;
//   }

//   /// Suma de gasto total de una categoría en todos los meses disponibles
//   double getTotalExpenseByCategory(ExpenseSubCategory subCategory) {
//     return state
//         .where(
//           (t) =>
//               t.type == TransactionType.expense && t.subCategory == subCategory,
//         )
//         .fold(0.0, (sum, t) => sum + t.amount);
//   }
// }

// // Inicialización del Provider
// final financeProvider =
//     StateNotifierProvider<FinanceNotifier, List<Transaction>>((ref) {
//       final asyncTransactions = ref.watch(transactionListNotifierProvider);
//       final list = asyncTransactions.value ?? [];
//       return FinanceNotifier(list);
//     });
