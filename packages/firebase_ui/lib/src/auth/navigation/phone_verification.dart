import 'package:firebase_ui/auth.dart';
import 'package:flutter/material.dart';

Future<void> startPhoneVerification({
  required BuildContext context,
  AuthAction? action,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PhoneInputScreen(action: action),
    ),
  );
}
