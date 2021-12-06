import 'package:flutter/material.dart';

abstract class NavigationAction {}

class NavigationActions extends InheritedWidget {
  final List<NavigationAction> actions;

  static T? ofType<T extends NavigationAction>(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<NavigationActions>();

    if (w == null) return null;

    for (final action in w.actions) {
      if (action is T) return action;
    }

    return null;
  }

  const NavigationActions({
    Key? key,
    required this.actions,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(NavigationActions oldWidget) {
    return oldWidget.actions != actions;
  }
}
