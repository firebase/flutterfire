import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/src/auth/theme/sign_in_screen_theme.dart';

import 'platform_widget.dart';

enum ButtonVariant {
  text,
  filled,
}

class UniversalButton extends PlatformWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final TextDirection? direction;
  final ButtonVariant variant;
  final SignInScreenTheme? signInScreenTheme;

  const UniversalButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.direction,
    this.variant = ButtonVariant.filled,
    this.signInScreenTheme,
  }) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    final child = Row(
      textDirection: direction,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: TextStyle(color: signInScreenTheme?.textColor),),
        if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 20)],
      ],
    );

    if (variant == ButtonVariant.text) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: child,
      );
    } else {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: child,
      );
    }
  }

  @override
  Widget buildMaterial(BuildContext context) {
    final child = Text(text, style: TextStyle(color: signInScreenTheme?.textColor),);

    if (icon != null) {
      if (variant == ButtonVariant.text) {
        return TextButton.icon(
          icon: Icon(icon),
          onPressed: onPressed,
          label: child,
        );
      } else {
        return ElevatedButton.icon(
          icon: Icon(icon),
          onPressed: onPressed,
          label: child,
        );
      }
    } else {
      if (variant == ButtonVariant.text) {
        return TextButton(
          onPressed: onPressed,
          child: child,
        );
      } else {}
      return ElevatedButton(
        onPressed: onPressed,
        child: child,
      );
    }
  }
}
