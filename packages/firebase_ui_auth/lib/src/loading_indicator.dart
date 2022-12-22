// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './widgets/internal/platform_widget.dart';

class LoadingIndicator extends PlatformWidget {
  final double size;
  final double borderWidth;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    required this.size,
    required this.borderWidth,
    this.color,
  }) : super(key: key);

  @override
  Widget? buildWrapper(BuildContext context, Widget child) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: child,
      ),
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return const CupertinoActivityIndicator();
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
