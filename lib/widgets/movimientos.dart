// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:the_finxup_app/screens/consumer_transaction_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class Movimientos extends StatelessWidget {
  const Movimientos({super.key});

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
      onDeleted: null, // Esto oculta el icono
      avatar: Icon(
        Icons.swap_horiz_rounded,
        size: 28,
        color: AppThemeHSL.textSecondary,
      ),
      label: Text(
        'Movimientos',
        style: TextStyle(color: AppThemeHSL.textSecondary, fontSize: 12),
      ),
    );
  }
}
