class LifestyleProfile {
  final String name;
  final String message;
  final String advice;
  final String
  statusColor; // Útil para pintar text/borders en Flutter (ej: 'green', 'red')
  final String? lottieAsset;
  final bool loopLottie; // Controlar si la animación se repite
  final double lottieHeight; // Altura personalizada

  LifestyleProfile({
    required this.name,
    required this.message,
    required this.advice,
    required this.statusColor,
    this.lottieAsset,
    this.loopLottie = true,
    this.lottieHeight = 120,
  });
}
