import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../auth_flow.dart';
import '../auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import '../oauth/oauth_providers.dart';
import '../configs/provider_configuration.dart';
import '../widgets/internal/oauth_provider_button_style.dart';

import '../flows/oauth_flow.dart';

abstract class OAuthProviderConfiguration<T extends OAuthProvider>
    extends ProviderConfiguration {
  const OAuthProviderConfiguration();

  Type get providerType => T;

  String get defaultRedirectUri =>
      'https://${Firebase.apps.first.options.projectId}.firebaseapp.com/__/auth/handler';

  ThemedOAuthProviderButtonStyle get style;

  @override
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action) {
    return OAuthFlow(
      auth: auth,
      action: action,
      config: this,
    );
  }

  T createProvider();

  String getLabel(FlutterFireUILocalizationLabels labels);
}
