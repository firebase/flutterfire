import 'package:firebase_auth/firebase_auth.dart'
    show
        AuthCredential,
        EmailAuthCredential,
        EmailAuthProvider,
        FirebaseAuth,
        UserCredential;

import 'package:firebase_ui/src/auth/auth_controller.dart';

import 'auth_flow.dart';

class AwaitingEmailAndPassword extends AuthState {}

class UserCreated extends AuthState {
  final UserCredential credential;

  UserCreated(this.credential);
}

abstract class EmailFlowController extends AuthController {
  void setEmailAndPassword(String email, String password);
}

class EmailFlow extends AuthFlow implements EmailFlowController {
  EmailFlow({
    required FirebaseAuth auth,
    required AuthMethod method,
  }) : super(
          method: method,
          initialState: AwaitingEmailAndPassword(),
          auth: auth,
        );

  @override
  void setEmailAndPassword(String email, String password) {
    setCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
  }

  @override
  Future<void> onCredentialReceived(AuthCredential credential) async {
    if (method == AuthMethod.signUp) {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: (credential as EmailAuthCredential).email,
        password: credential.password!,
      );

      value = UserCreated(userCredential);

      // TODO(@lesnitsky): handle email verification
      await signIn(credential);
    } else {
      await super.onCredentialReceived(credential);
    }
  }
}
