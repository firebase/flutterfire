import 'dart:async';

import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/auth/oauth/oauth_providers.dart';
import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:firebase_ui/src/auth/oauth/providers/apple_provider.dart';
import 'package:firebase_ui/src/firebase_ui_initializer.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;

import 'oauth/providers/google_provider.dart';

class FirebaseUIAuthOptions {
  final ActionCodeSettings? emailLinkSettings;

  FirebaseUIAuthOptions({
    this.emailLinkSettings,
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

  OAuthProvider resolveOAuthProvider<T extends OAuthProvider>() {
    // TODO(@lesnitsky): figure out tree-shaking
    switch (enumValueOf<T>()) {
      case OAuthProviders.google:
        return GoogleProviderImpl();
      case OAuthProviders.apple:
        return AppleProviderImpl();
    }

    throw Exception('Unknown OAuth provider type: $T');
  }
}
