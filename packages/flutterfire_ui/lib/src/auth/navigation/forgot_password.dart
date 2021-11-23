import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

Future<void> showForgotPasswordScreen(BuildContext context) async {
  final route = MaterialPageRoute(
    builder: (context) => ForgotPasswordScreen(),
  );

  await Navigator.of(context).push(route);
}
