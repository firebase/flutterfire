import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';

/// A screen displaying a fully styled phone number entry screen, with a country-code
/// picker.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying a fully styled phone number entry input with a country-code picker.}
/// {@subCategory img:https://place-hold.it/400x150}
class PhoneInputScreen extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;

  const PhoneInputScreen({
    Key? key,
    this.action,
    this.auth,
  }) : super(key: key);

  void next(BuildContext context, AuthAction? action, Object flowKey, _) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SMSCodeInputScreen(
          action: action,
          flowKey: flowKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flowKey = Object();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: PhoneInputView(
              flowKey: flowKey,
              onSMSCodeRequested: next,
            ),
          ),
        ),
      ),
    );
  }
}
