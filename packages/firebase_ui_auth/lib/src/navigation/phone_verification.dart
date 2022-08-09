import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/universal_page_route.dart';

/// Opens [PhoneInputScreen].
Future<void> startPhoneVerification({
  required BuildContext context,

  /// {@macro ui.auth.auth_action}
  AuthAction? action,

  /// {@macro ui.auth.auth_controller.auth}
  FirebaseAuth? auth,
}) async {
  await Navigator.of(context).push(
    createPageRoute(
      context: context,
      builder: (_) => FirebaseUIActions.inherit(
        from: context,
        child: PhoneInputScreen(
          auth: auth,
          action: action,
        ),
      ),
    ),
  );
}
