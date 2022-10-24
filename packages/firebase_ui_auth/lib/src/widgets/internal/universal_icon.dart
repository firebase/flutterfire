import 'package:firebase_ui_auth/src/widgets/internal/platform_widget.dart';
import 'package:flutter/widgets.dart';

class UniversalIcon extends PlatformWidget {
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final Color? color;
  final double? size;

  const UniversalIcon({
    Key? key,
    required this.cupertinoIcon,
    required this.materialIcon,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return Icon(
      cupertinoIcon,
      color: color,
      size: size,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return Icon(
      materialIcon,
      color: color,
      size: size,
    );
  }
}
