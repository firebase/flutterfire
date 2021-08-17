import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/firebase_ui.dart';

class Uninitialized extends AuthState {
  const Uninitialized();
}

abstract class OAuthController extends AuthController {
  void setOAuthCredential(OAuthCredential credential);
}

class OAuthFlow extends AuthFlow implements OAuthController {
  OAuthFlow({
    required AuthMethod method,
    required FirebaseAuth auth,
  }) : super(method: method, auth: auth, initialState: const Uninitialized());

  @override
  void setOAuthCredential(OAuthCredential credential) {
    setCredential(credential);
  }
}
