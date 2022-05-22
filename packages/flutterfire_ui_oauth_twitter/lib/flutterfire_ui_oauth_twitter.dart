export 'src/provider.dart' show TwitterProvider;
export 'src/theme.dart' show TwitterProviderButtonStyle;

import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

class TwiterSignInButton extends _TwiterSignInButton {
  const factory TwiterSignInButton.icon({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Widget loadingIndicator,
    required Future<void> Function() onTap,
  }) = TwiterSignInIconButton;

  const TwiterSignInButton({
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

class TwiterSignInIconButton extends TwiterSignInButton {
  const TwiterSignInIconButton({
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

class _TwiterSignInButton extends StatelessWidget {
  final ThemedOAuthProviderButtonStyle style;
  final String label;
  final Widget loadingIndicator;
  final Future<void> Function() onTap;

  const _TwiterSignInButton({
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
