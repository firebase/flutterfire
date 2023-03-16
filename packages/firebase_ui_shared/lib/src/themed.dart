import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// {@template ui.oauth.themed_value}
/// An object that is used to resolve the value base on the current theme
/// brightness.
/// {@endtemplate}
class ThemedValue<T> {
  /// The value that should be used to when the dark theme is used.
  final T dark;

  /// The value that should be used to when the light theme is used.
  final T light;

  const ThemedValue(this.dark, this.light);

  T getValue(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return dark;
      case Brightness.light:
        return light;
    }
  }
}

class ThemedColor extends ThemedValue<Color> {
  const ThemedColor(super.dark, super.light);
}

class ThemedIconSrc extends ThemedValue<String> {
  const ThemedIconSrc(super.dark, super.light);
}
