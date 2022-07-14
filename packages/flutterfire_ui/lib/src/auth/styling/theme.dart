import 'package:flutter/widgets.dart';

import 'style.dart';

typedef StylesMap = Map<Type, FlutterFireUIStyle>;

StylesMap _buildStylesMap(Set<FlutterFireUIStyle> styles) {
  return styles.fold({}, (acc, el) {
    return {
      ...acc,
      el.runtimeType: el,
    };
  });
}

/// FlutterFireUI styles provider widget.
///
/// Shouldn't be used if you're using pre-built screens, but could be used
/// if you're building your own and using only widgets from the FlutterFireUI.
class FlutterFireUITheme extends InheritedModel {
  /// A set of styles that need to be provded down the widget tree.
  final Set<FlutterFireUIStyle> styles;

  FlutterFireUITheme({
    Key? key,
    required Widget child,
    required this.styles,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(FlutterFireUITheme oldWidget) {
    return oldWidget.styles != styles;
  }

  @override
  bool updateShouldNotifyDependent(
    FlutterFireUITheme oldWidget,
    Set dependencies,
  ) {
    final oldStyles = _buildStylesMap(oldWidget.styles);
    final newStyles = _buildStylesMap(styles);

    return dependencies.any((element) {
      final oldStyle = oldStyles[element];
      final newStyle = newStyles[element];
      return oldStyle != newStyle;
    });
  }

  @override
  InheritedModelElement createElement() {
    return FlutterFireUIThemeElement(this);
  }
}

class FlutterFireUIThemeElement extends InheritedModelElement {
  FlutterFireUIThemeElement(InheritedModel widget) : super(widget);

  @override
  FlutterFireUITheme get widget => super.widget as FlutterFireUITheme;

  StylesMap styles = {};
  FlutterFireUIThemeElement? _parent;

  @override
  void mount(Element? parent, Object? newSlot) {
    _parent =
        parent?.getElementForInheritedWidgetOfExactType<FlutterFireUITheme>()
            as FlutterFireUIThemeElement?;

    if (_parent != null) {
      dependOnInheritedElement(_parent!);
    }

    styles = {
      if (_parent != null) ..._parent!.styles,
      ..._buildStylesMap(widget.styles),
    };

    super.mount(parent, newSlot);
  }
}
