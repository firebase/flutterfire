import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Subtitle extends StatelessWidget {
  final String text;
  const Subtitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final titleStyle = isCupertino
        ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
        : Theme.of(context).textTheme.subtitle1;

    return Text(
      text,
      style: titleStyle,
    );
  }
}
