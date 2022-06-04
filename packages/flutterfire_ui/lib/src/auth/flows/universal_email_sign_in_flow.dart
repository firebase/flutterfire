import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/auth_state.dart';

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
}
