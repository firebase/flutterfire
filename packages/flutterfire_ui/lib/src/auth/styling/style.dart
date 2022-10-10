import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/src/auth/styling/theme.dart';

abstract class FlutterFireUIStyle {
  const FlutterFireUIStyle();

  static T ofType<T extends FlutterFireUIStyle>(
    BuildContext context,
    T defaultValue,
  ) {
    final el =
        context.getElementForInheritedWidgetOfExactType<FlutterFireUITheme>();
    if (el == null) return defaultValue;

    context.dependOnInheritedElement(el, aspect: T);
    final style = (el as FlutterFireUIThemeElement).styles[T];

    if (style == null) return defaultValue;
    return style as T;
  }

  Widget applyToMaterialTheme(BuildContext context, Widget child) => child;
  Widget applyToCupertinoTheme(BuildContext context, Widget child) => child;

  Widget mount({required Widget child}) {
    return FlutterFireUITheme(
      styles: {this},
      child: child,
    );
  }
}
