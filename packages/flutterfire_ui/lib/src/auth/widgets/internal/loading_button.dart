import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback onTap;

  const LoadingButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    Widget child = Text(label);

    if (isLoading) {
      child = LoadingIndicator(
        size: isCupertino ? 20 : 16,
        borderWidth: 1,
      );
    }

    ButtonStyle? style;

    if (color != null) {
      style = ButtonStyle(
        foregroundColor: MaterialStateColor.resolveWith(
          (states) => color!,
        ),
        overlayColor: MaterialStateColor.resolveWith(
          (states) => color!.withAlpha(20),
        ),
      );
    }

    if (isCupertino) {
      if (icon != null) {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            child,
          ],
        );
      }

      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(
          primaryColor: color ?? CupertinoColors.activeBlue,
        ),
        child: CupertinoButton.filled(
          onPressed: onTap,
          child: child,
        ),
      );
    }

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: child,
        style: style,
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: style,
      child: child,
    );
  }
}
