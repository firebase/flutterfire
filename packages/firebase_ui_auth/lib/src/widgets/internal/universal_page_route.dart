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
