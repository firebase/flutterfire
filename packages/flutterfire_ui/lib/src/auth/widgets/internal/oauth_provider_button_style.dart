// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class ThemedValue<T> {
  final T dark;
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
  const ThemedColor(Color dark, Color light) : super(dark, light);
}

class ThemedIconSrc extends ThemedValue<String> {
  const ThemedIconSrc(
    String dark,
    String light,
  ) : super(dark, light);
}

abstract class ThemedOAuthProviderButtonStyle {
  ThemedIconSrc get iconSrc;
  ThemedColor get backgroundColor;
  ThemedColor get color;
  ThemedColor get iconBackgroundColor => backgroundColor;
  ThemedColor get borderColor => backgroundColor;
  double get iconPadding => 0;

  const ThemedOAuthProviderButtonStyle();

  OAuthProviderButtonStyle withBrightness(Brightness brightness) {
    return OAuthProviderButtonStyle(
      iconSrc: iconSrc.getValue(brightness),
      backgroundColor: backgroundColor.getValue(brightness),
      color: color.getValue(brightness),
      borderColor: borderColor.getValue(brightness),
    );
  }
}

class OAuthProviderButtonStyle {
  final String iconSrc;
  final Color backgroundColor;
  final Color color;
  final Color borderColor;

  OAuthProviderButtonStyle({
    required this.iconSrc,
    required this.backgroundColor,
    required this.color,
    required this.borderColor,
  });
}
