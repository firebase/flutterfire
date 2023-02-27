// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    Widget child;

    if (color != null) {
      final theme = Theme.of(context).textTheme.labelLarge;
      child = Text(
        label,
        style: theme?.copyWith(color: color),
      );
    } else {
      child = Text(label);
    }

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
  final Color? labelColor;
  final VoidCallback onTap;
  final ButtonVariant? variant;

  const LoadingButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.color,
    this.labelColor,
    this.variant = ButtonVariant.outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMaterial3 = theme.useMaterial3;

    final resolvedColor = variant == ButtonVariant.filled && !isMaterial3
        ? theme.colorScheme.onPrimary
        : null;

    final contentColor = labelColor ?? resolvedColor;

    final content = _LoadingButtonContent(
      label: label,
      isLoading: isLoading,
      color: contentColor,
    );

    return UniversalButton(
      color: color,
      icon: icon,
      contentColor: contentColor,
      onPressed: onTap,
      variant: variant,
      child: content,
    );
  }
}
