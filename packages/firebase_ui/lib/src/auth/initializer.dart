import 'dart:async';

import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/firebase_ui_initializer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUIAuthOptions {
  final FirebaseApp? app;
  final ActionCodeSettings? emailLinkSettings;

  FirebaseUIAuthOptions({
    this.emailLinkSettings,
    this.app,
  });
}

class FirebaseUIAuthInitializer
    extends FirebaseUIInitializer<FirebaseUIAuthOptions> {
  FirebaseUIAuthInitializer([FirebaseUIAuthOptions? params]) : super(params);

  late FirebaseAuth? _auth;
  FirebaseAuth get auth => _auth!;

  @override
  final dependencies = {FirebaseUIAppInitializer};

  @override
  Future<void> initialize([FirebaseUIAuthOptions? params]) async {
    final dep = resolveDependency<FirebaseUIAppInitializer>();
    _auth = FirebaseAuth.instanceFor(app: dep.app);
  }
}
