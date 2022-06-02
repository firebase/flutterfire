import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

import '../auth_state.dart';

class SendingLink extends AuthState {
  const SendingLink();
}

class AwaitingDynamicLink extends AuthState {
  const AwaitingDynamicLink();
}

abstract class EmailLinkAuthController extends AuthController {
  void sendLink(String email);
}

class EmailLinkFlow extends AuthFlow<EmailLinkAuthProvider>
    implements EmailLinkAuthController, EmailLinkAuthListener {
  EmailLinkFlow({
    FirebaseAuth? auth,
    required EmailLinkAuthProvider provider,
  }) : super(
          action: AuthAction.signIn,
          auth: auth,
          initialState: const Uninitialized(),
          provider: provider,
        );

  @override
  void sendLink(String email) {
    provider.sendLink(email);
  }

  @override
  void onBeforeLinkSent(String email) {
    value = const SendingLink();
  }

  @override
  void onLinkSent(String email) {
    value = const AwaitingDynamicLink();
    provider.awaitLink(email);
  }
}

class EmailLinkSignInAction extends FlutterFireUIAction {
  final void Function(BuildContext context) callback;

  EmailLinkSignInAction(this.callback);
}
