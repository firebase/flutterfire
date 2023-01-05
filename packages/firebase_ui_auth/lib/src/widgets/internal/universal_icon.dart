// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_auth/src/widgets/internal/platform_widget.dart';
import 'package:flutter/widgets.dart';

class UniversalIcon extends PlatformWidget {
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final Color? color;
  final double? size;

  const UniversalIcon({
    Key? key,
    required this.cupertinoIcon,
    required this.materialIcon,
    this.color,
    this.size,
  }) : super(key: key);

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
