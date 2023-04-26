// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// An icon widget that chooses between [cupertinoIcon] and [materialIcon]
/// depending on the type of App widget used ([CupertinoApp] or [MaterialApp]).
class UniversalIcon extends PlatformWidget {
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final Color? color;
  final double? size;

  const UniversalIcon({
    super.key,
    required this.cupertinoIcon,
    required this.materialIcon,
    this.color,
    this.size,
  });

  @override
  Widget buildCupertino(BuildContext context) {
    return Icon(
      cupertinoIcon,
      color: color,
      size: size,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return Icon(
      materialIcon,
      color: color,
      size: size,
    );
  }
}
