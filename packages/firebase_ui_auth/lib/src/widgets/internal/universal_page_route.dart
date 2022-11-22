// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route<T> createPageRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

  if (isCupertino) {
    return CupertinoPageRoute<T>(builder: builder);
  } else {
    return MaterialPageRoute<T>(builder: builder);
  }
}
