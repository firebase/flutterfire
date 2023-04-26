// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UniversalIconButton extends PlatformWidget {
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;

  const UniversalIconButton({
    super.key,
    this.onPressed,
    required this.cupertinoIcon,
    required this.materialIcon,
    this.size,
    this.color,
  });

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Icon(cupertinoIcon, size: size),
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return IconButton(
      color: color,
      iconSize: size,
      onPressed: onPressed,
      icon: Icon(materialIcon),
    );
  }
}
