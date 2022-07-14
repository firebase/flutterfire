import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/universal_page_route.dart';

/// Opens [PhoneInputScreen].
Future<void> startPhoneVerification({
  required BuildContext context,

  /// {@macro ffui.auth.auth_action}
  AuthAction? action,

  /// {@macro ffui.auth.auth_controller.auth}
  FirebaseAuth? auth,
}) async {
  await Navigator.of(context).push(
    createPageRoute(
      context: context,
      builder: (_) => FlutterFireUIActions.inherit(
        from: context,
        child: PhoneInputScreen(
          auth: auth,
          action: action,
        ),
      ),
    ),
  );
}
