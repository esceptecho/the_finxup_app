import 'package:flutter/material.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';
import 'package:the_finxup_app/widgets/colorize_names_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final schemeColor = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppThemeHSL.backgroundDeep, AppThemeHSL.backgroundDeep],
                focal: Alignment.center,
              ),
              borderRadius: BorderRadius.circular(15), // Sin bordes redondeados para un look moderno
              border: Border.all(
                color: AppThemeHSL.primary,
                width: 0.5,
                style: BorderStyle.none,
              ), // Borde sutil para destacar el contenedor
            ),
            // color: AppThemeHSL.backgroundDeep,
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Importante: Reduce el Column al tamaño de sus hijos
              children: [
                ColorizeNamesWidget(
                  names: ['F I N X U P'],
                  colors: [
                    AppThemeHSL.primary,
                    AppThemeHSL.accentGold,
                    AppThemeHSL.income,
                    AppThemeHSL.expense,
                    AppThemeHSL.accentGold,
                  ],
                  fontSize: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
