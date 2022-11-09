import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'universal_button.dart';

class _LoadingButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Color? color;
  const _LoadingButtonContent({
    Key? key,
    required this.label,
    required this.isLoading,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    Widget child = Text(label);

    if (isLoading) {
      child = LoadingIndicator(
        size: isCupertino ? 20 : 16,
        borderWidth: 1,
        color: color,
      );
    }

    return child;
  }
}

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback onTap;
  final ButtonVariant? variant;

  const LoadingButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.color,
    this.variant = ButtonVariant.outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = _LoadingButtonContent(
      label: label,
      isLoading: isLoading,
      color: variant == ButtonVariant.filled
          ? Theme.of(context).colorScheme.onPrimary
          : null,
    );

    return UniversalButton(
      color: color,
      icon: icon,
      onPressed: onTap,
      variant: variant,
      child: content,
    );
  }
}
