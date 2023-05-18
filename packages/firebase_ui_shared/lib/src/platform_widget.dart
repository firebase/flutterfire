// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform-aware widget that renders a different widget depending on the
/// type of the app. Requires implementation of [buildCupertino] if
/// [CupertinoApp] is used, and [buildMaterial] if [MaterialApp] is used.
/// Optionally, [buildWrapper] can be implemented to have a common wrapper
/// widget for both types of apps.
abstract class PlatformWidget extends StatelessWidget {
  const PlatformWidget({super.key});

  Widget buildCupertino(BuildContext context);
  Widget buildMaterial(BuildContext context);

  Widget? buildWrapper(BuildContext context, Widget child) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    late Widget child;

    if (isCupertino) {
      child = buildCupertino(context);
    } else {
      child = buildMaterial(context);
    }

    final wrapper = buildWrapper(context, child);

    if (wrapper == null) {
      return child;
    } else {
      return wrapper;
    }
  }
}
