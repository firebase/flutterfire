// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Subtitle extends PlatformWidget {
  final String text;
  final FontWeight? fontWeight;

  const Subtitle({
    super.key,
    required this.text,
    this.fontWeight,
  });

  @override
  Widget buildCupertino(BuildContext context) {
    return Text(
      text,
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontWeight: fontWeight),
    );
  }
}
