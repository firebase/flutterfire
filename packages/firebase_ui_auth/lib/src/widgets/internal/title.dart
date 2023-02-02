// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_widget.dart';

class Title extends PlatformWidget {
  final String text;
  const Title({Key? key, required this.text}) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return Text(
      text,
      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
