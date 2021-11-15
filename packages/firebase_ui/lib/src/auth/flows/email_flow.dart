import 'package:firebase_auth/firebase_auth.dart'
    show
        ActionCodeSettings,
        AuthCredential,
        EmailAuthCredential,
        EmailAuthProvider,
        FirebaseAuth,
        UserCredential;

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart'
    show FirebaseDynamicLinks;

import 'package:firebase_ui/src/auth/auth_controller.dart';

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

abstract class EmailFlowController extends AuthController {
  void setEmailAndPassword(String email, String password);
  Future<void> verifyEmail();
  Future<void> verifyDeepLink(Uri deepLink);
}

class EmailFlow extends AuthFlow implements EmailFlowController {
  EmailFlow({
    required this.config,
    FirebaseAuth? auth,
    AuthAction? action,
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
  Future<void> verifyDeepLink(Uri deepLink) async {
    try {
      final code = deepLink.queryParameters['oobCode']!;
      await auth.checkActionCode(code);
      await auth.applyActionCode(code);
      await auth.currentUser!.reload();

      value = EmailVerified();
    } on Exception catch (e) {
      value = EmailVerificationFailed(e);
    }
  }

  @override
  Future<void> verifyEmail([ActionCodeSettings? actionCodeSettings]) async {
    final settings = actionCodeSettings ?? config.actionCodeSettings;

    value = AwaitingEmailVerification();
    await auth.currentUser!.sendEmailVerification(settings);
  }

  @override
  Future<void> onCredentialReceived(AuthCredential credential) async {
    try {
      if (action == AuthAction.signUp) {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: (credential as EmailAuthCredential).email,
          password: credential.password!,
        );

        value = UserCreated(userCredential);

        await signIn(credential);
      } else {
        await super.onCredentialReceived(credential);
      }
    } on Exception catch (e) {
      value = AuthFailed(e);
    }
  }
}
