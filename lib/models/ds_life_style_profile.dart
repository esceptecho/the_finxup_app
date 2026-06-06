import 'package:flutter/material.dart';

class NewHealthStatusProfile {
  final String label;
  final IconData icon;
  final Color badgeColor;
  final String description; // NUEVO: explica el porqué

  NewHealthStatusProfile({
    required this.label,
    required this.icon,
    required this.badgeColor,
    required this.description,
  });
}

class NewLifestyleProfile {
  final String name;
  final String message;
  final String advice;
  final String statusColor;
  final String? lottieAsset; // opcional
  final bool loopLottie; // opcional
  final double lottieHeight; // opcional
  final String description; // NUEVO: explica el porqué

  NewLifestyleProfile({
    required this.name,
    required this.message,
    required this.advice,
    required this.statusColor,
    this.lottieAsset,
    this.loopLottie = false,
    this.lottieHeight = 150,
    required this.description,
  });
}
