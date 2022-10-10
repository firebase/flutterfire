import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/universal_page_route.dart';

Future<void> startPhoneVerification({
  required BuildContext context,
  AuthAction? action,
  FirebaseAuth? auth,
}) async {
  await Navigator.of(context).push(
    createPageRoute(
      context: context,
      builder: (_) => FlutterFireUIActions.inherit(
        from: context,
        child: PhoneInputScreen(action: action),
      ),
    ),
  );
}
