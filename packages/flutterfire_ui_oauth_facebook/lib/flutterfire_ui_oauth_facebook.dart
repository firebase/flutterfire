export 'src/provider.dart' show FacebookProvider;
export 'src/theme.dart' show FacebookProviderButtonStyle;

import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

class FacebbokSignInButton extends _FacebbokSignInButton {
  const factory FacebbokSignInButton.icon({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required Future<void> Function() onTap,
  }) = FacebbokSignInIconButton;

  const FacebbokSignInButton({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required String label,
    required Future<void> Function() onTap,
  }) : super(
          key: key,
          style: style,
          label: label,
          loadingIndicator: loadingIndicator,
          onTap: onTap,
        );
}

class FacebbokSignInIconButton extends FacebbokSignInButton {
  const FacebbokSignInIconButton({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required Future<void> Function() onTap,
  }) : super(
          key: key,
          style: style,
          loadingIndicator: loadingIndicator,
          onTap: onTap,
          label: '',
        );
}

class _FacebbokSignInButton extends StatelessWidget {
  final ThemedOAuthProviderButtonStyle style;
  final String label;
  final Widget loadingIndicator;
  final Future<void> Function() onTap;

  const _FacebbokSignInButton({
    Key? key,
    required this.label,
    required this.loadingIndicator,
    required this.style,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OAuthProviderButton(
      style: style,
      label: label,
      onTap: onTap,
      loadingIndicator: loadingIndicator,
    );
  }
}
