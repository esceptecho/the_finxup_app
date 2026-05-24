import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          // color: Colors.amber
          color: AppThemeHSL.income.withValues(alpha: 0.8),
          ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Importante: Reduce el Column al tamaño de sus hijos 
            children: [
              Text(
                'Toma decisiones basadas en datos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppThemeHSL.textPrimary.withValues(alpha: 0.9)),
                softWrap: true,
                textAlign: .center,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Define un ancho fijo
                height: 300, // Define un alto fijo
                child: Lottie.asset(
                  "assets/lotties/Financial_charts_statistics.json",
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
