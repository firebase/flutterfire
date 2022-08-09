import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_widget.dart';

class UniversalScaffold extends PlatformWidget {
  final Widget body;

  /// See [Scaffold.resizeToAvoidBottomInset]
  final bool? resizeToAvoidBottomInset;

  const UniversalScaffold({
    Key? key,
    required this.body,
    this.resizeToAvoidBottomInset,
  }) : super(key: key);

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      child: body,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}
