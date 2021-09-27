import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show AuthCredential, User;

abstract class AuthState {
  const AuthState();

  static AuthState of(BuildContext context) => maybeOf(context)!;

  static AuthState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthStateProvider>()?.state;
}

class SigningIn extends AuthState {
  const SigningIn();
}

class CredentialReceived extends AuthState {
  final AuthCredential credential;

  CredentialReceived(this.credential);
}

class CredentialLinked extends AuthState {
  final AuthCredential credential;

  CredentialLinked(this.credential);
}

class AuthFailed extends AuthState {
  final Exception exception;

  AuthFailed(this.exception);
}

class SignedIn extends AuthState {
  final User user;

  SignedIn(this.user);
}

class AuthStateProvider extends InheritedWidget {
  final AuthState state;

  AuthStateProvider({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(AuthStateProvider oldWidget) {
    return state != oldWidget.state;
  }
}
