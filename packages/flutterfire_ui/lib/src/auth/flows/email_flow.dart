import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutterfire_ui/auth.dart';

import '../auth_flow.dart';

class AwaitingEmailAndPassword extends AuthState {}

class UserCreated extends AuthState {
  final fba.UserCredential credential;

  UserCreated(this.credential);
}

class SigningUp extends AuthState {}

abstract class EmailAuthController extends AuthController {
  void setEmailAndPassword(String email, String password);
}

class EmailAuthFlow extends AuthFlow<EmailAuthProvider>
    implements EmailAuthController, EmailAuthListener {
  @override
  final EmailAuthProvider provider;

  EmailAuthFlow({
    required this.provider,
    fba.FirebaseAuth? auth,
    AuthAction? action,
  }) : super(
          action: action,
          initialState: AwaitingEmailAndPassword(),
          auth: auth,
          provider: provider,
        );

  @override
  void setEmailAndPassword(String email, String password) {
    final credential = fba.EmailAuthProvider.credential(
      email: email,
      password: password,
    ) as fba.EmailAuthCredential;

    provider.onCredentialReceived(credential, action);
  }
}
