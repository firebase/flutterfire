import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthState {}

class UninitializedAuthState extends AuthState {}

abstract class AuthFlow extends ValueNotifier<AuthState> {
  late final FirebaseAuth auth;
  final _credentialCompleter = Completer<AuthCredential>();
  Future<AuthCredential> get credentials => _credentialCompleter.future;

  AuthFlow() : super(UninitializedAuthState());

  void setCredentials(AuthCredential credential) {
    _credentialCompleter.complete(credential);
  }
}
