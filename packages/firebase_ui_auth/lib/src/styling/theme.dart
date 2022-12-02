// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'style.dart';

typedef StylesMap = Map<Type, FirebaseUIStyle>;

StylesMap _buildStylesMap(Set<FirebaseUIStyle> styles) {
  return styles.fold({}, (acc, el) {
    return {
      ...acc,
      el.runtimeType: el,
    };
  });
}

/// FirebaseUI styles provider widget.
///
/// Shouldn't be used if you're using pre-built screens, but could be used
/// if you're building your own and using only widgets from the FirebaseUI.
class FirebaseUITheme extends InheritedModel {
  /// A set of styles that need to be provded down the widget tree.
  final Set<FirebaseUIStyle> styles;

  const FirebaseUITheme({
    Key? key,
    required Widget child,
    required this.styles,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(FirebaseUITheme oldWidget) {
    return oldWidget.styles != styles;
  }

  @override
  bool updateShouldNotifyDependent(
    FirebaseUITheme oldWidget,
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
    return FirebaseUIThemeElement(this);
  }
}

class FirebaseUIThemeElement extends InheritedModelElement {
  FirebaseUIThemeElement(InheritedModel widget) : super(widget);

  @override
  FirebaseUITheme get widget => super.widget as FirebaseUITheme;

  StylesMap styles = {};
  FirebaseUIThemeElement? _parent;

  @override
  void mount(Element? parent, Object? newSlot) {
    _parent = parent?.getElementForInheritedWidgetOfExactType<FirebaseUITheme>()
        as FirebaseUIThemeElement?;

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
