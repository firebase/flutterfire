import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

import '../auth_state.dart';

/// A controller interface of the [OAuthFlow].
abstract class OAuthController extends AuthController {
  /// Triggers a sign in.
  void signIn(TargetPlatform platform);
}

/// {@template ffui.auth.flows.oauth_flow}
/// A flow that allows to authenticate using OAuth providers.
/// {@endtemplate}
class OAuthFlow extends AuthFlow<OAuthProvider>
    implements OAuthController, OAuthListener {
  /// {@macro ffui.auth.flows.oauth_flow}
  OAuthFlow({
    /// {@macro ffui.auth.auth_flow.ctor.provider}
    required OAuthProvider provider,

    /// {@macro @macro ffui.auth.auth_action}
    AuthAction? action,

    /// {@macro ffui.auth.auth_controller.auth}
    FirebaseAuth? auth,
  }) : super(
          action: action,
          auth: auth,
          initialState: const Uninitialized(),
          provider: provider,
        );

  @override
  void signIn(TargetPlatform platform) {
    provider.signIn(platform, action);
  }
}
