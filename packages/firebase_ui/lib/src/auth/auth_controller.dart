import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, FirebaseAuth, User;
import 'package:flutter/widgets.dart';

enum AuthMethod {
  signIn,
  signUp,
  link,
}

abstract class AuthController {
  static AuthController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AuthControllerProvider>()!
        .ctrl;
  }

  AuthMethod get method;

  FirebaseAuth get auth;

  Future<User?> signIn(AuthCredential credential);
  Future<void> link(AuthCredential credential);
}

class AuthControllerProvider extends InheritedWidget {
  final AuthMethod method;
  final AuthController ctrl;

  AuthControllerProvider({
    required Widget child,
    required this.method,
    required this.ctrl,
  }) : super(child: child);

  @override
  bool updateShouldNotify(AuthControllerProvider oldWidget) {
    return ctrl != oldWidget.ctrl || method != oldWidget.method;
  }
}
