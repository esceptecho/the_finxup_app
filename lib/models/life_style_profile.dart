class LifestyleProfile {
  final String name;
  final String message;
  final String advice;
  final String
  statusColor; // Útil para pintar text/borders en Flutter (ej: 'green', 'red')

  LifestyleProfile({
    required this.name,
    required this.message,
    required this.advice,
    required this.statusColor,
  });
}
