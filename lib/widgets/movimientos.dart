// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:the_finxup_app/screens/consumer_transaction_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class Movimientos extends StatefulWidget {
  const Movimientos({super.key});

  @override
  State<Movimientos> createState() => _MovimientosState();
}

class _MovimientosState extends State<Movimientos> {
  @override
  Widget build(BuildContext context) {
    return InputChip(
      backgroundColor: AppThemeHSL.surfaceLighter,
      shape: StadiumBorder(
        side: BorderSide(color: AppThemeHSL.textHint, width: .3),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConsumerTransactionsScreen(),
          ),
        );
      },
      onDeleted: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConsumerTransactionsScreen(openAddModal: true),
          ),
        );
      }, // Esto oculta el icono
      deleteIcon: Icon(Icons.add, size: 24),
      avatar: Icon(
        Icons.swap_horiz_rounded,
        size: 24,
        color: AppThemeHSL.textSecondary,
      ),
      label: Text(
        'Movimientos',
        style: TextStyle(color: AppThemeHSL.textSecondary, fontSize: 12),
      ),
    );
  }
}
