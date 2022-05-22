import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';
import 'package:flutterfire_ui_oauth_apple/flutterfire_ui_oauth_apple.dart';
import 'package:flutterfire_ui_oauth_facebook/flutterfire_ui_oauth_facebook.dart';
import 'package:flutterfire_ui_oauth_google/flutterfire_ui_google_oauth.dart';
import 'package:flutterfire_ui_oauth_twitter/flutterfire_ui_oauth_twitter.dart';

import 'src/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const OAuthProviderButtonExample());
}

class OAuthProviderButtonExample extends StatelessWidget {
  const OAuthProviderButtonExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Settings(builder: (context, library, brightness, buttonVariant) {
      if (library == DesignLibrary.material) {
        return MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: Content(
              designLibrary: library,
              buttonVariant: buttonVariant,
            ),
          ),
        );
      } else {
        return CupertinoApp(
          theme: CupertinoThemeData(brightness: brightness),
          home: CupertinoPageScaffold(
            child: Content(
              designLibrary: library,
              buttonVariant: buttonVariant,
            ),
          ),
        );
      }
    });
  }
}

class Content extends StatefulWidget {
  final DesignLibrary designLibrary;
  final ButtonVariant buttonVariant;

  const Content({
    Key? key,
    required this.designLibrary,
    required this.buttonVariant,
  }) : super(key: key);

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  Future<void> _onTap() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.buttonVariant == ButtonVariant.full
        ? OAuthProviderButton.new
        : OAuthProviderIconButton.new;

    final loadingIndicator = widget.designLibrary == DesignLibrary.material
        ? const CircularProgressIndicator()
        : const CupertinoActivityIndicator();

    return Center(
      child: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(
              style: const AppleProviderButtonStyle(),
              label: 'Sign in with Apple',
              onTap: _onTap,
              loadingIndicator: loadingIndicator,
            ),
            button(
              style: const FacebookProviderButtonStyle(),
              label: 'Sign in with Facebook',
              onTap: _onTap,
              loadingIndicator: loadingIndicator,
            ),
            button(
              style: const GoogleProviderButtonStyle(),
              label: 'Sign in with Google',
              onTap: _onTap,
              loadingIndicator: loadingIndicator,
            ),
            button(
              style: const TwitterProviderButtonStyle(),
              label: 'Sign in with Twitter',
              onTap: _onTap,
              loadingIndicator: loadingIndicator,
            ),
          ],
        ),
      ),
    );
  }
}
