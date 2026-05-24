import 'dart:math';

import 'package:flutter/widgets.dart';

final List<AssetImage> assetImageList = [
  const AssetImage('assets/avatar_placeholder.jpeg'),
  const AssetImage('assets/arees_profile.jpeg'),
  const AssetImage('assets/dark-banner3.png'),
  const AssetImage('assets/fondo-degradado1.jpg'),
  const AssetImage('assets/naufrago-ilustration.png'),
  const AssetImage('assets/banner2.png'),
  const AssetImage('assets/depb_trap_ilustration.png'),
  const AssetImage('assets/fondo-degradado2.jpg'),
  const AssetImage('assets/investment-goal-4tips.png'),
  const AssetImage('assets/banner4.png'),
  const AssetImage('assets/dev-app-flow.png'),
  const AssetImage('assets/fondo-degradado3.jpg'),
  const AssetImage('assets/joven-comoda.png'),
  const AssetImage('assets/banner5.png'),
  const AssetImage('assets/diseño-reglas-financiera.png'),
  const AssetImage('assets/fondo-degradado4.jpg'),
  const AssetImage('assets/jubilados-ancianos.png'),
  const AssetImage('assets/banner6.png'),
  const AssetImage('assets/en-la-cima.png'),
  const AssetImage('assets/fondo-degradado5.jpg'),
  const AssetImage('assets/login.png'),
  const AssetImage('assets/banner.png'),
  const AssetImage('assets/finanzas-personales.png'),
  const AssetImage('assets/fondo_degradado_login.png'),
  const AssetImage('assets/logo-cup-dark.png'),
  const AssetImage('assets/buho-retro.png'),
  const AssetImage('assets/finGoals.png'),
  const AssetImage('assets/fondo_finzup.png'),
  const AssetImage('assets/logo-cup.png'),
  const AssetImage('assets/buho-silueta0.jpg'),
  const AssetImage('assets/FinzUp_logo.png'),
  const AssetImage('assets/fondo_linea_vert.png'),
  const AssetImage('assets/logoMFUp2.png'),
  const AssetImage('assets/buho-silueta1.jpg'),
  const AssetImage('assets/finzup.png'),
  const AssetImage('assets/fondo-retro.jpg'),
  const AssetImage('assets/logoMFUp.png'),
  const AssetImage('assets/buho-silueta2.jpg'),
  const AssetImage('assets/finzup_splash_logo.png'),
  const AssetImage('assets/fondo-simple0.jpg'),
  const AssetImage('assets/logoMiFinanzApp.png'),
  const AssetImage('assets/buho-silueta.jpg'),
  const AssetImage('assets/fondo0.jpg'),
  const AssetImage('assets/fondo-simple1.jpg'),
  const AssetImage('assets/logo.png'),
  const AssetImage('assets/buho-silueta-mini.jpg'),
  const AssetImage('assets/fondo-1.jpg'),
  const AssetImage('assets/fondo-simple2.jpg'),
  const AssetImage('assets/logo-simple-conmorado.png'),
  const AssetImage('assets/buho-silueta-retro.jpg'),
  const AssetImage('assets/fondo1.jpg'),
  const AssetImage('assets/fondo-simple3.jpg'),
  const AssetImage('assets/logo-simple.png'),
  const AssetImage('assets/student-goal-4tips.png'),
  const AssetImage('assets/student-goal.png'),
  const AssetImage('assets/student-goal-tips.png'),
  const AssetImage('assets/student.png'),
  const AssetImage('assets/tipFinz.png'),
  const AssetImage('assets/UI-UX.png'),
  const AssetImage('assets/vacaciones.png'),
  const AssetImage('assets/vida-lujosa.png'),

];

// Si prefieres usar Image.asset en lugar de AssetImage, puedes hacer:
final List<String> assetPathList = [
  'assets/avatar_placeholder.jpeg',
  'assets/dark-banner3.png',
  'assets/fondo-degradado1.jpg',
  'assets/naufrago-ilustration.png',
  'assets/banner2.png',
  'assets/depb_trap_ilustration.png',
  'assets/fondo-degradado2.jpg',
  'assets/investment-goal-4tips.png',
  'assets/banner4.png',
  'assets/dev-app-flow.png',
  'assets/fondo-degradado3.jpg',
  'assets/joven-comoda.png',
  'assets/banner5.png',
  'assets/diseño-reglas-financiera.png',
  'assets/fondo-degradado4.jpg',
  'assets/jubilados-ancianos.png',
  'assets/banner6.png',
  'assets/en-la-cima.png',
  'assets/fondo-degradado5.jpg',
  'assets/login.png',
  'assets/banner.png',
  'assets/finanzas-personales.png',
  'assets/fondo_degradado_login.png',
  'assets/logo-cup-dark.png',
  'assets/buho-retro.png',
  'assets/finGoals.png',
  'assets/fondo_finzup.png',
  'assets/logo-cup.png',
  'assets/buho-silueta0.jpg',
  'assets/FinzUp_logo.png',
  'assets/fondo_linea_vert.png',
  'assets/logoMFUp2.png',
  'assets/buho-silueta1.jpg',
  'assets/finzup.png',
  'assets/fondo-retro.jpg',
  'assets/logoMFUp.png',
  'assets/buho-silueta2.jpg',
  'assets/finzup_splash_logo.png',
  'assets/fondo-simple0.jpg',
  'assets/logoMiFinanzApp.png',
  'assets/buho-silueta.jpg',
  'assets/fondo0.jpg',
  'assets/fondo-simple1.jpg',
  'assets/logo.png',
  'assets/buho-silueta-mini.jpg',
  'assets/fondo-1.jpg',
  'assets/fondo-simple2.jpg',
  'assets/logo-simple-conmorado.png',
  'assets/buho-silueta-retro.jpg',
  'assets/fondo1.jpg',
  'assets/fondo-simple3.jpg',
  'assets/logo-simple.png',
  'assets/student-goal-4tips.png',
  'assets/student-goal.png',
  'assets/student-goal-tips.png',
  'assets/student.png',
  'assets/tipFinz.png',
  'assets/UI-UX.png',
  'assets/vacaciones.png',
  'assets/vida-lujosa.png',
];

// Comparar por ruta
bool areSameImage(String path1, String path2) {
  return path1 == path2;
}

// Encontrar imagen por nombre o parte de la ruta
AssetImage getImageByName(String fileName) {
  String path = assetPathList.firstWhere(
    (path) => path.contains(fileName),
    orElse: () => assetPathList.first,
  );
  return AssetImage(path);
}

// Función para obtener un elemento aleatorio
String getRandomAsset() {
  final random = Random();
  // Genera un índice entre 0 y la longitud de la lista - 1
  int index = random.nextInt(assetPathList.length);
  return assetPathList[index];
}

final shuffledAssetPathList = assetPathList.shuffle();

// Uso
final image1 = getImageByName('logo.png');
final image2 = getImageByName('logo.png');
// Son la misma si la ruta es igual
// Ejemplo de uso con Image.asset:
// Image.asset(assetPathList[0]) // Muestra avatar_placeholder.jpeg
// Image.asset(assetPathList[1]) // Muestra dark-banner3.png

