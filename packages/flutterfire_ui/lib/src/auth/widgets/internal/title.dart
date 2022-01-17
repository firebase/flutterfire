import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_widget.dart';

class Title extends PlatformWidget {
  final String text;
  final Color? color;
  const Title({Key? key, required this.text, this.color}) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return Text(
      text,
      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline5?.copyWith(color: color),
    );
  }
}
