import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfire_ui/auth.dart';

import 'oauth_provider_button_style.dart';

typedef ErrorCallback = void Function(Exception e);

enum OAuthButtonVariant {
  icon_and_text,
  icon,
}

class OAuthProviderButtonContent extends StatelessWidget {
  final String label;
  final OAuthProviderButtonStyle style;
  final double size;
  const OAuthProviderButtonContent({
    Key? key,
    required this.label,
    required this.style,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = AuthState.of(context) is SigningIn;
    late Widget content;

    if (isLoading) {
      final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

      if (isCupertino) {
        return const LoadingIndicator(size: 16, borderWidth: 1);
      }
      content = const SizedBox.shrink();
    } else {
      content = Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          height: 1.1,
          color: style.color,
          fontSize: size,
        ),
      );
    }

    return content;
  }
}

class OAuthProviderButtonTapHandler extends StatelessWidget {
  final double borderRadius;
  final Function(BuildContext context) onTap;

  const OAuthProviderButtonTapHandler({
    Key? key,
    required this.borderRadius,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoading = AuthState.of(context) is SigningIn;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () {
          if (isLoading) return;
          onTap(context);
        },
      ),
    );
  }
}

mixin SignInWithOAuthProviderMixin {
  void signIn(BuildContext context) {
    final ctrl = AuthController.ofType<OAuthController>(context);
    final targetPlatform = Theme.of(context).platform;
    ctrl.signInWithProvider(targetPlatform);
  }
}

class _ErrorListener extends StatelessWidget {
  const _ErrorListener({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = AuthState.of(context);
    if (state is AuthFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ErrorText(exception: state.exception),
      );
    }

    return const SizedBox.shrink();
  }
}

class OAuthProviderButton extends StatelessWidget
    with SignInWithOAuthProviderMixin {
  final double size;
  final AuthAction? action;
  final FirebaseAuth? auth;
  final double _padding;
  final OAuthProviderConfiguration providerConfig;
  final VoidCallback? onTap;
  final bool overrideDefaultAction;

  const OAuthProviderButton({
    Key? key,
    required this.providerConfig,
    this.action,
    this.auth,
    this.size = 19,
    this.onTap,
    this.overrideDefaultAction = false,
  })  : _padding = size * 1.33 / 2,
        super(key: key);

  double get _height => size + _padding * 2;

  @override
  Widget build(BuildContext context) {
    final brightness =
        CupertinoTheme.of(context).brightness ?? Theme.of(context).brightness;
    final style = providerConfig.style.withBrightness(brightness);
    final l = FlutterFireUILocalizations.labelsOf(context);

    final margin = (size + _padding * 2) / 10;
    final borderRadius = size / 3;
    const borderWidth = 1.0;
    final iconBorderRadius = borderRadius - borderWidth;

    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    if (isCupertino) {
      return AuthFlowBuilder<OAuthController>(
        action: action,
        auth: auth,
        config: providerConfig,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: margin),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  primaryColor: style.backgroundColor,
                ),
                child: Builder(
                  builder: (context) => CupertinoButton.filled(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: SizedBox(
                      height: _height,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(iconBorderRadius),
                              bottomLeft: Radius.circular(iconBorderRadius),
                            ),
                            child: SizedBox(
                              width: _height,
                              height: _height,
                              child: SvgPicture.asset(
                                style.iconSrc,
                                package: 'flutterfire_ui',
                                width: size,
                                height: size,
                              ),
                            ),
                          ),
                          Expanded(
                            child: OAuthProviderButtonContent(
                              label: providerConfig.getLabel(l),
                              style: style,
                              size: size,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      onTap?.call();
                      if (!overrideDefaultAction) {
                        signIn(context);
                      }
                    },
                  ),
                ),
              ),
            ),
            const _ErrorListener(),
          ],
        ),
      );
    }

    return AuthFlowBuilder<OAuthController>(
      action: action,
      auth: auth,
      config: providerConfig,
      child: Column(
        children: [
          Container(
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
                      child: SizedBox(
                        height: _height,
                        child: Row(
                          children: [
                            SizedBox(
                              width: _height,
                              height: _height,
                              child: SvgPicture.asset(
                                style.iconSrc,
                                package: 'flutterfire_ui',
                                width: size,
                                height: size,
                              ),
                            ),
                            Expanded(
                              child: OAuthProviderButtonContent(
                                label: providerConfig.getLabel(l),
                                style: style,
                                size: size,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: OAuthProviderButtonTapHandler(
                    borderRadius: borderRadius,
                    onTap: onTap != null ? (context) => onTap!() : signIn,
                  ),
                ),
                Builder(
                  builder: (context) {
                    bool isLoading = AuthState.of(context) is SigningIn;

                    if (isLoading) {
                      return Positioned.fill(
                        child: LoadingIndicator(
                          size: size,
                          borderWidth: borderWidth,
                          color: style.color,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )
              ],
            ),
          ),
          const _ErrorListener(),
        ],
      ),
    );
  }
}

abstract class OAuthProviderButtonWidget extends StatelessWidget {
  const OAuthProviderButtonWidget({Key? key}) : super(key: key);

  OAuthProviderConfiguration get providerConfig;
  AuthAction? get action;
  FirebaseAuth? get auth;
  double? get size;

  VoidCallback? get onTap;

  @override
  Widget build(BuildContext context) {
    return OAuthProviderButton(
      providerConfig: providerConfig,
      action: action,
      auth: auth,
      size: size ?? 19,
      onTap: onTap,
    );
  }
}

class OAuthProviderIconButton extends StatelessWidget
    with SignInWithOAuthProviderMixin {
  final double size;
  final FirebaseAuth? auth;
  final AuthAction? action;
  final OAuthProviderConfiguration providerConfig;
  final VoidCallback? onTap;
  final bool overrideDefaultAction;

  const OAuthProviderIconButton({
    Key? key,
    required this.providerConfig,
    this.size = 44,
    this.auth,
    this.action,
    this.onTap,
    this.overrideDefaultAction = false,
  }) : super(key: key);

  WidgetBuilder _contentBuilder(
    BorderRadius borderRadius,
    OAuthProviderButtonStyle style,
  ) =>
      (BuildContext context) {
        bool isLoading = AuthState.of(context) is SigningIn;

        if (isLoading) {
          return LoadingIndicator(
            borderWidth: 1,
            size: size / 2,
            color: style.color,
          );
        }
        return ClipRRect(
          borderRadius: borderRadius,
          child: SvgPicture.asset(
            style.iconSrc,
            package: 'flutterfire_ui',
            width: size,
            height: size,
          ),
        );
      };

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final style = providerConfig.style.withBrightness(brightness);
    final borderRadius = BorderRadius.circular(size / 6);

    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    if (isCupertino) {
      return AuthFlowBuilder<OAuthController>(
        auth: auth,
        action: action,
        config: providerConfig,
        child: Container(
          width: size,
          height: size,
          margin: EdgeInsets.all(size / 10),
          child: CupertinoTheme(
            data: CupertinoThemeData(
              primaryColor: style.backgroundColor,
            ),
            child: Builder(
              builder: (context) => CupertinoButton.filled(
                padding: EdgeInsets.zero,
                child: Builder(builder: _contentBuilder(borderRadius, style)),
                onPressed: () {
                  onTap?.call();
                  if (!overrideDefaultAction) {
                    signIn(context);
                  }
                },
              ),
            ),
          ),
        ),
      );
    }

    return AuthFlowBuilder<OAuthController>(
      auth: auth,
      action: action,
      config: providerConfig,
      child: Container(
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
              child: Builder(
                builder: _contentBuilder(borderRadius, style),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: Builder(
                  builder: (context) {
                    return InkWell(
                      onTap: () {
                        onTap?.call();

                        if (!overrideDefaultAction) {
                          signIn(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class OAuthProviderIconButtonWidget extends StatelessWidget {
  const OAuthProviderIconButtonWidget({Key? key}) : super(key: key);

  OAuthProviderConfiguration get providerConfig;
  FirebaseAuth? get auth;
  AuthAction? get action;
  double? get size;
  VoidCallback? get onTap;

  @override
  Widget build(BuildContext context) {
    return OAuthProviderIconButton(
      auth: auth,
      action: action,
      size: size ?? 44,
      providerConfig: providerConfig,
    );
  }
}
