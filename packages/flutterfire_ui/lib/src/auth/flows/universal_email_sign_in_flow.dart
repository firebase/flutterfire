import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/auth_flow.dart';
import 'package:flutterfire_ui/src/auth/auth_state.dart';
import 'package:flutterfire_ui/src/auth/providers/universal_email_sign_in_provider.dart';

abstract class UniversalEmailSignInController extends AuthController {}

class UniversalEmailSignInFlow extends AuthFlow<UniversalEmailSignInProvider>
    implements UniversalEmailSignInController, UniversalEmailSignInListener {
  UniversalEmailSignInFlow({
    required UniversalEmailSignInProvider provider,
    FirebaseAuth? auth,
    AuthAction? action,
  }) : super(
          initialState: const Uninitialized(),
          provider: provider,
          auth: auth,
          action: action,
        );

  void resolveProviers(String email) {
    provider.fetchDifferentProvidersForEmail(email);
  }
}
