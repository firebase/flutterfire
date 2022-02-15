import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import 'decorations.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      body: ForgotPasswordScreen(
        email: arguments?['email'],
        headerMaxExtent: 200,
        headerBuilder: headerIcon(Icons.lock),
        sideBuilder: sideIcon(Icons.lock),
      ),
    );
  }
}
