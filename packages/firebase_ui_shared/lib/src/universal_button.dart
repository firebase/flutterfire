// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// {@template ui.shared.widgets.button_variant}
/// An enumeration of the possible button variants.
/// {@endtemplate}
enum ButtonVariant {
  /// button variant that is rendered as a text without a background or border.
  text,

  /// button variant that has a background.
  filled,

  /// button variant that has a border.
  outlined,
}

/// Button widget that uses [CupertinoButton] under [CupertinoApp] and
/// [TextButton], [ElevatedButton] or [OutlinedButton] under [MaterialApp]
/// depending on provided [variant].
class UniversalButton extends PlatformWidget {
  /// A callback that is called when the button is pressed.
  final VoidCallback? onPressed;

  /// The text to display in the button.
  /// If [child] is provided, this will be ignored.
  final String? text;

  /// The child to display in the button.
  final Widget? child;

  /// The icon to display in the button under [MaterialApp].
  final IconData? materialIcon;

  /// The icon to display in the button under [CupertinoApp].
  final IconData? cupertinoIcon;

  /// Defines the order of the icon and the label.
  /// Icon will be placed on the left if [TextDirection.ltr] and on the right
  /// if [TextDirection.rtl].
  final TextDirection? direction;

  /// The variant of the button.
  /// If not provided, [ButtonVariant.filled] will be used.
  final ButtonVariant variant;

  /// The color of the button background under [MaterialApp].
  final Color? materialColor;

  /// The color of the button background under [CupertinoApp].
  final Color? cupertinoColor;

  /// The color of the button content.
  final Color? contentColor;

  const UniversalButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.materialIcon,
    this.cupertinoIcon,
    this.direction = TextDirection.ltr,
    this.variant = ButtonVariant.filled,
    this.materialColor,
    this.cupertinoColor,
    this.contentColor,
  }) : assert(text != null || child != null);

  @override
  Widget buildCupertino(BuildContext context) {
    late Widget button;

    final child = Row(
      textDirection: direction,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cupertinoIcon != null) ...[
          if (direction == TextDirection.rtl) const SizedBox(width: 8),
          Icon(cupertinoIcon, size: 20, color: contentColor),
          if (direction == TextDirection.ltr) const SizedBox(width: 8),
        ],
        this.child ?? Text(text!),
      ],
    );

    if (variant == ButtonVariant.text || variant == ButtonVariant.outlined) {
      button = CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: child,
      );
    } else {
      button = CupertinoButton.filled(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: child,
      );
    }

    if (cupertinoColor != null) {
      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(primaryColor: cupertinoColor),
        child: button,
      );
    } else {
      return button;
    }
  }

  @override
  Widget buildMaterial(BuildContext context) {
    final child = this.child ?? Text(text!);

    ButtonStyle? style;

    if (materialColor != null) {
      MaterialStateColor? foregroundColor;
      MaterialStateColor? backgroundColor;

      if (variant == ButtonVariant.text) {
        foregroundColor = MaterialStateColor.resolveWith((_) => materialColor!);
      } else {
        foregroundColor = MaterialStateColor.resolveWith((_) => contentColor!);
        backgroundColor = MaterialStateColor.resolveWith((_) => materialColor!);
      }

      style = ButtonStyle(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        overlayColor: MaterialStateColor.resolveWith(
          (states) => materialColor!.withAlpha(20),
        ),
      );
    }

    if (materialIcon != null) {
      switch (variant) {
        case ButtonVariant.text:
          return TextButton.icon(
            icon: Icon(materialIcon, color: contentColor),
            onPressed: onPressed,
            label: child,
            style: style,
          );
        case ButtonVariant.filled:
          return ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(materialIcon, color: contentColor),
            label: child,
            style: style,
          );
        case ButtonVariant.outlined:
          return OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(materialIcon, color: contentColor),
            label: child,
            style: style,
          );
      }
    } else {
      switch (variant) {
        case ButtonVariant.text:
          return TextButton(
            onPressed: onPressed,
            style: style,
            child: child,
          );
        case ButtonVariant.filled:
          return ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: child,
          );
        case ButtonVariant.outlined:
          return OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: child,
          );
      }
    }
  }
}
