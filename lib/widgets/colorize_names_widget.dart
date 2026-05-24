import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ColorizeNamesWidget extends StatelessWidget {
  final List<String> names;
  final List<Color> colors;
  final double fontSize;
  final VoidCallback? onTap;

  const ColorizeNamesWidget({
    super.key,
    this.names = const ['F i n x U p', 'Arees','Tu Finanzas', 'Tu Futuro', 'F i n x U p'],
    this.colors = const [
      Colors.deepPurple,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ],
    this.fontSize = 50.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos el estilo dentro del build para mantenerlo organizado
    final colorizeTextStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: 'Horizon',
      fontWeight: FontWeight.bold,
    );

    return SizedBox(
      width: 250.0,
      child: AnimatedTextKit(
        isRepeatingAnimation: false,
        onTap: onTap ?? () => print("Tap Event"),
        animatedTexts: names.map((name) => ColorizeAnimatedText(
          name,
          textStyle: colorizeTextStyle,
          colors: colors,
          textAlign: TextAlign.center,
        )).toList(),
      ),
    );
  }
}