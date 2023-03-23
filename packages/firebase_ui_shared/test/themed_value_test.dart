// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_ui_shared/firebase_ui_shared.dart';

void main() {
  group('ThemedValue', () {
    test('returns a value for light theme', () {
      const themedValue = ThemedValue(Colors.white, Colors.black);
      expect(themedValue.getValue(Brightness.light), Colors.black);
    });

    test('returns a value for dark theme', () {
      const themedValue = ThemedValue(Colors.white, Colors.black);
      expect(themedValue.getValue(Brightness.dark), Colors.white);
    });
  });

  group('ThemedColor', () {
    test('returns a color for light theme', () {
      const themedColor = ThemedColor(Colors.white, Colors.black);
      expect(themedColor.getValue(Brightness.light), Colors.black);
    });

    test('returns a color for dark theme', () {
      const themedColor = ThemedColor(Colors.white, Colors.black);
      expect(themedColor.getValue(Brightness.dark), Colors.white);
    });
  });

  group('ThemedIconSrc', () {
    test('returns an src for light theme', () {
      const themedIconSrc = ThemedIconSrc('light.png', 'dark.png');
      expect(themedIconSrc.getValue(Brightness.light), 'dark.png');
    });

    test('returns an src for dark theme', () {
      const themedIconSrc = ThemedIconSrc('light.png', 'dark.png');
      expect(themedIconSrc.getValue(Brightness.dark), 'light.png');
    });
  });
}
