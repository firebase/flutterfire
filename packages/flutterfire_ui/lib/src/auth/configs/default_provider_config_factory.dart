import 'package:flutterfire_ui/auth.dart';

ProviderConfiguration createDefaltProviderConfig<T extends AuthController>() {
  switch (T) {
    case EmailFlowController:
      return const EmailProviderConfiguration();
    case OAuthController:
      throw Exception("Can't create default OAuthProviderConfiguration");
    case PhoneAuthController:
      return const PhoneProviderConfiguration();
    default:
      throw Exception("Can't create ProviderConfiguration for $T");
  }
}
