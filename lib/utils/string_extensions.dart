import 'package:flutter/material.dart';

extension StringCasing on String {
  /// Capitaliza solo la primera letra de la cadena
  /// 'hola mundo' -> 'Hola mundo'
  String toCapitalized() {
    if (isEmpty) return this;
    return splitMapJoin(
      RegExp(r'^.'),
      onMatch: (match) => match.group(0)!.toUpperCase(),
      onNonMatch: (nonMatch) => nonMatch,
    );
  }

  /// Capitaliza la primera letra de cada palabra
  /// 'hola mundo' -> 'Hola Mundo'
  String toTitleCase() {
    if (isEmpty) return this;
    return splitMapJoin(
      RegExp(r'\b\w'),
      onMatch: (match) => match.group(0)!.toUpperCase(),
      onNonMatch: (nonMatch) => nonMatch,
    );
  }
}

// myText.toTitleCase()
// myText.toCapitalized()
