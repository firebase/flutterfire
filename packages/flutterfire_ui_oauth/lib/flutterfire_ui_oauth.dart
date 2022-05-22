export 'package:firebase_auth/firebase_auth.dart' show OAuthCredential;
export 'package:desktop_webview_auth/desktop_webview_auth.dart'
    show AuthResult, ProviderArgs;
export 'package:desktop_webview_auth/google.dart';
export 'package:desktop_webview_auth/facebook.dart';
export 'package:desktop_webview_auth/twitter.dart';

export './src/oauth_provider.dart';
export './src/oauth_provider_button.dart';
export './src/oauth_provider_button_style.dart';

export 'src/sign_out_mixin.dart'
    if (dart.library.html) 'src/sign_out_mixin_web.dart';

class AuthCancelledException implements Exception {
  AuthCancelledException([this.message = 'User has cancelled auth']);

  final String message;
}
