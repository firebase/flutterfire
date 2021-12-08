import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../auth_controller.dart';
import '../configs/email_provider_configuration.dart';
import '../auth_flow.dart';
import '../auth_state.dart';

class AwaitingEmailAndPassword extends AuthState {}

class UserCreated extends AuthState {
  final UserCredential credential;

  UserCreated(this.credential);
}

class AwaitingEmailVerification extends AuthState {}

class EmailVerificationFailed extends AuthState {
  final Exception exception;

  EmailVerificationFailed(this.exception);
}

class EmailVerified extends AuthState {}

class SigningUp extends AuthState {}

abstract class EmailFlowController extends AuthController {
  void setEmailAndPassword(String email, String password);
  Future<void> verifyEmail([ActionCodeSettings? actionCodeSettings]);
}

class EmailFlow extends AuthFlow implements EmailFlowController {
  final FirebaseDynamicLinks? dynamicLinks;

  EmailFlow({
    required this.config,
    FirebaseAuth? auth,
    AuthAction? action,
    this.dynamicLinks,
  }) : super(
          action: action,
          initialState: AwaitingEmailAndPassword(),
          auth: auth,
        );

  final EmailProviderConfiguration config;

  @override
  void setEmailAndPassword(String email, String password) {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    setCredential(credential);
  }

  @override
  Future<void> verifyEmail([ActionCodeSettings? actionCodeSettings]) async {
    final settings = actionCodeSettings ?? config.actionCodeSettings;

    value = AwaitingEmailVerification();
    await auth.currentUser!.sendEmailVerification(settings);
    final linkData =
        await (dynamicLinks ?? FirebaseDynamicLinks.instance).onLink.first;

    try {
      final code = linkData.link.queryParameters['oobCode']!;
      await auth.checkActionCode(code);
      await auth.applyActionCode(code);
      await auth.currentUser!.reload();

      value = EmailVerified();
    } on Exception catch (e) {
      value = EmailVerificationFailed(e);
    }
  }

  @override
  Future<void> onCredentialReceived(AuthCredential credential) async {
    try {
      if (action == AuthAction.signUp) {
        value = SigningUp();

        final userCredential = await auth.createUserWithEmailAndPassword(
          email: (credential as EmailAuthCredential).email,
          password: credential.password!,
        );

        value = UserCreated(userCredential);

        action = AuthAction.signIn;
        await super.onCredentialReceived(credential);
      } else {
        await super.onCredentialReceived(credential);
      }
    } on Exception catch (e) {
      value = AuthFailed(e);
    }
  }
}
