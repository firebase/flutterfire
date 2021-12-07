import 'package:flutter/cupertino.dart';

abstract class PlatformWidget extends StatelessWidget {
  const PlatformWidget({Key? key}) : super(key: key);

  Widget buildCupertino(BuildContext context);
  Widget buildMaterial(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    if (isCupertino) {
      return buildCupertino(context);
    } else {
      return buildMaterial(context);
    }
  }
}
