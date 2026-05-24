import 'dart:math';

final List<String> welcomeUpdateVideos = [
  'assets/videos/BienvenidosEscepTechOS0.mp4',
  'assets/videos/Despedid_corta_EscepTechOS.mp4',
  'assets/videos/Despedida_EscepTechOS.mp4',
  'assets/videos/Presentacion-EscepTechOS.mp4',
];

final _random = Random();

String getRandomWelcomeVideo() {
  return welcomeUpdateVideos[_random.nextInt(welcomeUpdateVideos.length)];
}
