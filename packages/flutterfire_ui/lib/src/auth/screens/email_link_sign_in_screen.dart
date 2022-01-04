import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

import 'internal/responsive_page.dart';
import '../widgets/internal/universal_scaffold.dart';

class EmailLinkSignInScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final EmailLinkProviderConfiguration config;
  final List<FlutterFireUIAction>? actions;
  final HeaderBuilder? headerBuilder;
  final double? headerMaxExtent;
  final SideBuilder? sideBuilder;
  final TextDirection? desktoplayoutDirection;

  const EmailLinkSignInScreen({
    Key? key,
    this.auth,
    this.actions,
    required this.config,
    this.headerBuilder,
    this.headerMaxExtent,
    this.sideBuilder,
    this.desktoplayoutDirection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterFireUIActions(
      actions: actions ?? const [],
      child: UniversalScaffold(
        body: ResponsivePage(
          breakpoint: 400,
          headerBuilder: headerBuilder,
          headerMaxExtent: headerMaxExtent,
          maxWidth: 1200,
          sideBuilder: sideBuilder,
          desktopLayoutDirection: desktoplayoutDirection,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: EmailLinkSignInView(
              auth: auth,
              config: config,
            ),
          ),
        ),
      ),
    );
  }
}
