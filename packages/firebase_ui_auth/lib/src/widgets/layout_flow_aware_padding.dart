// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// Padding widget that takes into account current layout flow.
/// If nearest ancestor is [Row] (or [Flex] with [Flex.direction] equal to
/// [Axis.horizontal]) – horizontal paddings are ignored.
/// Otherwise vertical paddings are ignored.
class LayoutFlowAwarePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const LayoutFlowAwarePadding({
    Key? key,
    required this.child,
    required this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Axis? axis;

    context.visitAncestorElements((element) {
      if (element.widget is Row) {
        axis = Axis.horizontal;
        return false;
      } else if (element.widget is Column) {
        axis = Axis.vertical;
        return false;
      } else if (element.widget is Flex) {
        axis = (element.widget as Flex).direction;
        return false;
      }

      return true;
    });

    EdgeInsets finalPadding;

    if (axis == null) {
      finalPadding = padding;
    } else if (axis == Axis.horizontal) {
      finalPadding = EdgeInsets.only(
        left: padding.left,
        right: padding.right,
      );
    } else {
      finalPadding = EdgeInsets.only(
        top: padding.top,
        bottom: padding.bottom,
      );
    }

    return Padding(
      padding: finalPadding,
      child: child,
    );
  }
}
