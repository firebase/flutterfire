// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

typedef KeyboardPositionListener = void Function(double position);

class KeyboardAppearenceListener extends StatefulWidget {
  final Widget child;
  final KeyboardPositionListener listener;
  const KeyboardAppearenceListener({
    Key? key,
    required this.child,
    required this.listener,
  }) : super(key: key);

  @override
  State<KeyboardAppearenceListener> createState() =>
      _KeyboardAppearenceListenerState();
}

class _KeyboardAppearenceListenerState
    extends State<KeyboardAppearenceListener> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    widget.listener(bottom);
    super.didChangeDependencies();
  }
}
