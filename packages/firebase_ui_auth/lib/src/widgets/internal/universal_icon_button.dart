import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_widget.dart';

class UniversalIconButton extends PlatformWidget {
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;

  const UniversalIconButton({
    Key? key,
    this.onPressed,
    required this.cupertinoIcon,
    required this.materialIcon,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Icon(cupertinoIcon, size: size),
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return IconButton(
      color: color,
      iconSize: size,
      onPressed: onPressed,
      icon: Icon(materialIcon),
    );
  }
}
