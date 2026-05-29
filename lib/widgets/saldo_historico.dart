// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:the_finxup_app/providers/transaction_notifiers.dart';

// class SaldoTotalHistoricoWidget extends ConsumerWidget {
//   const SaldoTotalHistoricoWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final saldoTotal = ref.watch(saldoTotalHistoricoProvider);

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: saldoTotal >= 0
//               ? [Colors.green.shade400, Colors.green.shade600]
//               : [Colors.red.shade400, Colors.red.shade600],
//         ),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'SALDO TOTAL HISTÓRICO',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '\$${saldoTotal.toStringAsFixed(2)}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Desde el inicio hasta hoy',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
