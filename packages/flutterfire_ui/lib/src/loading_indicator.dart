import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double borderWidth;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    required this.size,
    required this.borderWidth,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget indicator;

    if (CupertinoUserInterfaceLevel.maybeOf(context) != null) {
      indicator = const CupertinoActivityIndicator();
    } else {
      final _color = color ?? Theme.of(context).colorScheme.secondary;
      indicator = CircularProgressIndicator(
        strokeWidth: borderWidth * 2,
        valueColor: AlwaysStoppedAnimation<Color>(_color),
      );
    }

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: indicator,
      ),
    );
  }
}
