// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A loading indicator that uses [CupertinoActivityIndicator] under
/// [CupertinoApp] and [CircularProgressIndicator] under [MaterialApp].
///
/// Centered by default.
class LoadingIndicator extends PlatformWidget {
  /// The size of the loading indicator.
  final double size;

  /// The width of the loading indicator's border.
  /// This is only used for [CircularProgressIndicator] under [MaterialApp].
  final double borderWidth;

  /// The color of the loading indicator.
  /// This is only used for [CircularProgressIndicator] under [MaterialApp].
  final Color? color;

  const LoadingIndicator({
    super.key,
    required this.size,
    required this.borderWidth,
    this.color,
  });

  @override
  Widget? buildWrapper(BuildContext context, Widget child) {
    return SizedBox(
      width: size,
      height: size,
      child: child,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: size / 2,
      color: color,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    final valueColor = color ?? Theme.of(context).colorScheme.secondary;

    return CircularProgressIndicator(
      strokeWidth: borderWidth * 2,
      valueColor: AlwaysStoppedAnimation<Color>(valueColor),
    );
  }
}
