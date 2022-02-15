import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/startup.dart';

import 'decorations.dart';

class EmailLink extends StatelessWidget {
  const EmailLink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmailLinkSignInScreen(
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            Navigator.pushReplacementNamed(context, '/profile');
          }),
        ],
        config: emailLinkProviderConfig,
        headerMaxExtent: 200,
        headerBuilder: headerIcon(Icons.link),
        sideBuilder: sideIcon(Icons.link),
      ),
    );
  }
}
