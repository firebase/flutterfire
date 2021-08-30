import 'package:firebase_ui/src/auth/oauth/provider_resolvers.dart';
import 'package:flutter/material.dart';

import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/src/auth/oauth/oauth_flow.dart';
import 'package:flutter_svg/svg.dart';

import '../oauth_providers.dart';

class ProviderButton<T extends OAuthProvider> extends StatelessWidget {
  final double size;
  final double _padding;

  const ProviderButton({
    Key? key,
    this.size = 19,
  })  : _padding = size * 1.33 / 2,
        super(key: key);

  double get _height => size + _padding * 2;

  static ProviderButton<T> icon<T extends OAuthProvider>({double size = 44}) =>
      ProviderIconButton<T>(size: size);

  void signIn(BuildContext context) {
    final ctrl = AuthController.of(context) as OAuthController;
    ctrl.signInWithProvider<T>();
  }

  @override
  Widget build(BuildContext context) {
    final style = buttonStyle<T>().withBrightness(Theme.of(context).brightness);

    final margin = (size + _padding * 2) / 10;
    final borderRadius = size / 3;
    const borderWidth = 1.0;
    final iconBorderRadius = borderRadius - borderWidth;

    return Container(
      margin: EdgeInsets.symmetric(vertical: margin),
      child: Stack(
        children: [
          Material(
            elevation: 1,
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: style.backgroundColor),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconBorderRadius),
                child: Row(
                  children: [
                    SizedBox(
                      width: _height,
                      height: _height,
                      child: SvgPicture.asset(
                        style.iconSrc,
                        package: 'firebase_ui',
                        width: size,
                        height: size,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Sign in with $T',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.1,
                          color: style.color,
                          fontSize: size,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: () {
                  signIn(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProviderIconButton<T extends OAuthProvider> extends ProviderButton<T> {
  const ProviderIconButton({Key? key, double size = 44})
      : super(key: key, size: size);
  @override
  Widget build(BuildContext context) {
    final style = buttonStyle<T>().withBrightness(Theme.of(context).brightness);
    final borderRadius = BorderRadius.circular(size / 6);

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.all(size / 10),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(size / 6),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: SvgPicture.asset(
              style.iconSrc,
              package: 'firebase_ui',
              width: size,
              height: size,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  signIn(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
