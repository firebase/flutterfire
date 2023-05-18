// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// {@template ui.shared.themed_value}
/// Helper class that helps to resolve a value based on the current app
/// [Brightness].
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

/// A [ThemedValue] that resolves to [Color].
///
/// ```dart
/// final textColor = ThemedColor(Colors.white, Colors.black);
///
/// color.getValue(Brightness.dark); // Colors.black
/// color.getValue(Brightness.light); // Colors.white
/// ```
class ThemedColor extends ThemedValue<Color> {
  const ThemedColor(super.dark, super.light);
}

/// A [ThemedValue] that resolves to [String].
///
/// ```dart
/// final iconSrc = ThemedIconSrc(
///   'assets/icon_light.png',
///   'assets/icon_dark.png',
/// );
///
/// iconSrc.getValue(Brightness.dark); // 'assets/icon_light.png'
/// iconSrc.getValue(Brightness.light); // 'assets/icon_dark.png'
/// ```
class ThemedIconSrc extends ThemedValue<String> {
  const ThemedIconSrc(super.dark, super.light);
}
