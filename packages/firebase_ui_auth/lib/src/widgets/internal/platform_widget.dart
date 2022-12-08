// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';

abstract class PlatformWidget extends StatelessWidget {
  const PlatformWidget({Key? key}) : super(key: key);

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
