import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/src/auth/provider_configuration.dart';

import 'email_provider_configuration.dart';
import 'phone_provider_configuration.dart';

ProviderConfiguration createDefaltProviderConfig<T extends AuthController>() {
  switch (T) {
    case EmailFlowController:
      return EmailProviderConfiguration();
    case OAuthController:
      throw Exception("Can't create default OAuthProviderConfiguration");
    case PhoneAuthController:
      return PhoneProviderConfiguration();
    default:
      throw Exception("Can't create ProviderConfiguration for $T");
  }
}
