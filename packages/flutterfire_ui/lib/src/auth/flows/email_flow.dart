import 'package:firebase_auth/firebase_auth.dart' as fba;

import '../auth_controller.dart';
import '../auth_flow.dart';
import '../auth_state.dart';

class AwaitingEmailAndPassword extends AuthState {}

class UserCreated extends AuthState {
  final fba.UserCredential credential;

  UserCreated(this.credential);
}

class SigningUp extends AuthState {}

abstract class AuthListener {
  AuthProvider get provider;

  void onError(Object error);

  void onBeforeSignIn();
  void onSignedIn(fba.UserCredential credential);

  void onBeforeCredentialLinked(fba.AuthCredential credential);
  void onCredentialLinked(fba.AuthCredential credential);

  void onBeforeProvidersForEmailFetch();
  void onDifferentProvidersFound(String email, List<String> providers, fba.AuthCredential? credential,);
}

abstract class AuthProvider<T extends AuthListener, K extends fba.AuthCredential> {
  late final fba.FirebaseAuth auth;
  T get authListener;
  set authListener(T listener);

  AuthProvider();

  void signInWithCredential(fba.AuthCredential credential) {
    authListener.onBeforeSignIn();
    auth
        .signInWithCredential(credential)
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }

  void linkWithCredential(fba.AuthCredential credential) {
    authListener.onBeforeCredentialLinked(credential);
    try {
      final user = auth.currentUser!;
      user
          .linkWithCredential(credential)
          .then((_) => authListener.onCredentialLinked(credential))
          .catchError(authListener.onError);
    } on fba.FirebaseAuthException catch (err) {
      authListener.onError(err);
    }
  }

  void fetchDifferentProvidersForEmail(String email, fba.AuthCredential? credential) {
    authListener.onBeforeProvidersForEmailFetch();

    auth
        .fetchSignInMethodsForEmail(email)
        .then((methods) => authListener.onDifferentProvidersFound(email, methods, credential))
        .catchError(authListener.onError);
  }

  void onCredentialReceived(K credential, AuthAction action) {
    if (action == AuthAction.link) {
      linkWithCredential(credential);
    } else {
      signInWithCredential(credential);
    }
  }
}

abstract class EmailAuthListener extends AuthListener {}

class EmailAuthProvider extends AuthProvider<EmailAuthListener, fba.EmailAuthCredential> {
  @override
  late EmailAuthListener authListener;

  void signUpWithCredential(fba.EmailAuthCredential credential) {
    authListener.onBeforeSignIn();
    auth
        .createUserWithEmailAndPassword(email: credential.email, password: credential.password!)
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }

  @override
  void onCredentialReceived(fba.EmailAuthCredential credential, AuthAction action) {
    if (action == AuthAction.signUp) {
      signUpWithCredential(credential);
    } else {
      super.onCredentialReceived(credential, action);
    }
  }
}

abstract class EmailFlowController extends AuthController {
  void setEmailAndPassword(String email, String password);
}

class EmailFlow extends AuthFlow<EmailAuthProvider> implements EmailFlowController, EmailAuthListener {
  @override
  final EmailAuthProvider provider;

  EmailFlow({
    required this.provider,
    fba.FirebaseAuth? auth,
    AuthAction? action,
  }) : super(
          action: action,
          initialState: AwaitingEmailAndPassword(),
          auth: auth,
          provider: provider,
        )

  @override
  void setEmailAndPassword(String email, String password) {
    final credential = fba.EmailAuthProvider.credential(
      email: email,
      password: password,
    ) as fba.EmailAuthCredential;

    provider.onCredentialReceived(credential, action);
  }
}
