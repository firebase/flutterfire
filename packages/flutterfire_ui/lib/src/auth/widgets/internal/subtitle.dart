import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_widget.dart';

class Subtitle extends PlatformWidget {
  final String text;
  final FontWeight? fontWeight;

  const Subtitle({
    Key? key,
    required this.text,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return Text(
      text,
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .subtitle1!
          .copyWith(fontWeight: fontWeight),
    );
  }
}
