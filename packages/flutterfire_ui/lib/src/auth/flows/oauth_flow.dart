import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

import '../auth_flow.dart';
import '../auth_state.dart';

abstract class OAuthController extends AuthController {
  void signIn(TargetPlatform platform);
}

class OAuthFlow extends AuthFlow<OAuthProvider> implements OAuthController {
  OAuthFlow({
    required OAuthProvider provider,
    AuthAction? action,
    FirebaseAuth? auth,
  }) : super(
          action: action,
          auth: auth,
          initialState: const Uninitialized(),
          provider: provider,
        );

  @override
  void signIn(TargetPlatform platform) {
    provider.platformSignIn(platform, action);
  }
}
