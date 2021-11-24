import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    Widget child = Text(label);

    if (isLoading) {
      child = const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(strokeWidth: 1),
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
