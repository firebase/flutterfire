// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';

/// {@template ui.oauth.oauth_provider_button_base.error_builder}
/// A builder that is invoked to build a widget that indicates an error.
/// {@endtemplate}
typedef ErrorBuilder = Widget Function(Exception e);

/// {@template ui.oauth.oauth_provider_button_base.different_providers_found_callback}
/// A callback that is being called when there are different oauth providers
/// associated with the same email.
/// {@endtemplate}
typedef DifferentProvidersFoundCallback = void Function(
  List<String> providers,
  AuthCredential? credential,
);

/// {@template ui.oauth.oauth_provider_button_base.signed_in_callback}
/// A callback that is being called when the user signs in.
/// {@endtemplate}
typedef SignedInCallback = void Function(UserCredential credential);

/// {@template ui.oauth.oauth_provider_button_base}
/// A base widget that allows authentication using OAuth providers.
/// {@endtemplate}
class OAuthProviderButtonBase extends StatefulWidget {
  /// {@template ui.oauth.oauth_provider_button.label}
  /// Text that would be displayed on the button.
  /// {@endtemplate}
  final String label;

  /// {@template ui.oauth.oauth_provider_button.size}
  /// Font size of the button label. Padding of the buttons is calculated to
  /// meet the provider design requirements.
  /// {@endtemplate}
  final double size;
  final double _padding;

  /// {@template ui.oauth.oauth_provider_button.loading_indicator}
  /// A widget that would be displayed while the button is in loading state.
  /// {@endtemplate}
  final Widget loadingIndicator;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@template ui.oauth.oauth_provider_button.on_tap}
  /// A callback that is being called when the button is tapped.
  /// {@endtemplate}
  final void Function()? onTap;

  /// {@template ui.oauth.oauth_provider}
  final OAuthProvider provider;

  /// {@macro ui.oauth.oauth_provider_button_base.different_providers_found_callback}
  final DifferentProvidersFoundCallback? onDifferentProvidersFound;

  /// {@macro ui.oauth.oauth_provider_button_base.signed_in_callback}
  final SignedInCallback? onSignedIn;

  /// {@macro ui.oauth.oauth_provider_button_base.on_error}
  /// A callback that is being called when an error occurs.
  /// {@endtemplate}
  final void Function(Exception exception)? onError;

  /// {@macro ui.oauth.oauth_provider_button_base.on_cancelled}
  /// A callback that is being called when the user cancels the sign in.
  /// {@endtemplate}
  final VoidCallback? onCancelled;

  /// {@template ui.oauth.oauth_provider_button_base.override_default_tap_action}
  /// Indicates whether the default tap action should be overridden.
  /// If set to `true`, authentcation logic is not executed and should be
  /// handled by the user.
  /// {@endtemplate}
  final bool overrideDefaultTapAction;

  /// {@template ui.oauth.oauth_provider_button_base.is_loading}
  /// Indicates whether the sign in process is in progress.
  /// {@endtemplate}
  final bool isLoading;

  const OAuthProviderButtonBase({
    Key? key,

    /// {@macro ui.oauth.oauth_provider_button.label}
    required this.label,

    /// {@macro ui.oauth.oauth_provider_button.loading_indicator}
    required this.loadingIndicator,

    /// {@macro ui.oauth.oauth_provider}
    required this.provider,

    /// {@macro ui.oauth.oauth_provider_button.on_tap}
    this.onTap,

    /// {@macro ui.auth.auth_controller.auth}
    this.auth,

    /// {@macro ui.auth.auth_action}
    this.action,

    /// {@macro ui.oauth.oauth_provider_button_base.different_providers_found_callback}
    this.onDifferentProvidersFound,

    /// {@macro ui.oauth.oauth_provider_button_base.signed_in_callback}
    this.onSignedIn,

    /// {@macro ui.oauth.oauth_provider_button_base.override_default_tap_action}
    this.overrideDefaultTapAction = false,

    /// {@macro ui.oauth.oauth_provider_button.size}
    this.size = 19,

    /// {@macro ui.oauth.oauth_provider_button_base.is_loading}
    this.isLoading = false,

    /// {@macro ui.oauth.oauth_provider_button_base.on_error}
    this.onError,

    /// {@macro ui.oauth.oauth_provider_button_base.on_cancelled}
    this.onCancelled,
  })  : assert(!overrideDefaultTapAction || onTap != null),
        _padding = size * 1.33 / 2,
        super(key: key);

  @override
  State<OAuthProviderButtonBase> createState() =>
      _OAuthProviderButtonBaseState();
}

class _OAuthProviderButtonBaseState extends State<OAuthProviderButtonBase>
    implements OAuthListener {
  double get _height => widget.size + widget._padding * 2;
  late bool isLoading = widget.isLoading;

  @override
  void initState() {
    super.initState();

    widget.provider.auth = widget.auth ?? FirebaseAuth.instance;
    widget.provider.authListener = this;
  }

  void _signIn() {
    final platform = Theme.of(context).platform;

    if (widget.overrideDefaultTapAction) {
      widget.onTap!.call();
    } else {
      provider.signIn(platform, widget.action ?? AuthAction.signIn);
    }
  }

  Widget _buildCupertino(
    BuildContext context,
    OAuthProviderButtonStyle style,
    double margin,
    double borderRadius,
    double iconBorderRadius,
  ) {
    final br = BorderRadius.circular(borderRadius);

    return LayoutFlowAwarePadding(
      padding: EdgeInsets.all(margin),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          primaryColor: widget.label.isEmpty
              ? style.iconBackgroundColor
              : style.backgroundColor,
        ),
        child: Material(
          elevation: 1,
          borderRadius: br,
          child: CupertinoButton.filled(
            padding: const EdgeInsets.all(0),
            borderRadius: br,
            onPressed: _signIn,
            child: ClipRRect(
              borderRadius: br,
              child: _ButtonContent(
                assetsPackage: style.assetsPackage,
                iconSrc: style.iconSrc,
                iconPadding: style.iconPadding,
                isLoading: isLoading,
                label: widget.label,
                height: _height,
                fontSize: widget.size,
                textColor: style.color,
                loadingIndicator: widget.loadingIndicator,
                borderRadius: br,
                borderColor: style.borderColor,
                iconBackgroundColor: style.iconBackgroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterial(
    BuildContext context,
    OAuthProviderButtonStyle style,
    double margin,
    double borderRadius,
    double iconBorderRadius,
  ) {
    final br = BorderRadius.circular(borderRadius);

    return _ButtonContainer(
      borderRadius: br,
      color: widget.label.isEmpty
          ? style.iconBackgroundColor
          : style.backgroundColor,
      height: _height,
      width: widget.label.isEmpty ? _height : null,
      margin: margin,
      child: Stack(
        children: [
          _ButtonContent(
            assetsPackage: style.assetsPackage,
            iconSrc: style.iconSrc,
            iconPadding: style.iconPadding,
            isLoading: isLoading,
            label: widget.label,
            height: _height,
            fontSize: widget.size,
            textColor: style.color,
            loadingIndicator: widget.loadingIndicator,
            borderRadius: br,
            borderColor: style.borderColor,
            iconBackgroundColor: style.iconBackgroundColor,
          ),
          _MaterialForeground(onTap: () => _signIn()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final brightness =
        CupertinoTheme.of(context).brightness ?? Theme.of(context).brightness;

    final style = provider.style.withBrightness(brightness);
    final margin = (widget.size + widget._padding * 2) / 10;
    final borderRadius = widget.size / 3;
    const borderWidth = 1.0;
    final iconBorderRadius = borderRadius - borderWidth;

    if (isCupertino) {
      return _buildCupertino(
        context,
        style,
        margin,
        borderRadius,
        iconBorderRadius,
      );
    } else {
      return _buildMaterial(
        context,
        style,
        margin,
        borderRadius,
        iconBorderRadius,
      );
    }
  }

  @override
  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;

  @override
  void onCredentialReceived(AuthCredential credential) {
    setState(() {
      isLoading = true;
    });
  }

  @override
  void onMFARequired(MultiFactorResolver resolver) {
    startMFAVerification(context: context, resolver: resolver);
  }

  @override
  void onBeforeProvidersForEmailFetch() {
    setState(() {
      isLoading = true;
    });
  }

  @override
  void onBeforeSignIn() {
    setState(() {
      isLoading = true;
    });
  }

  @override
  void onCredentialLinked(AuthCredential credential) {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void onDifferentProvidersFound(
    String email,
    List<String> providers,
    AuthCredential? credential,
  ) {
    widget.onDifferentProvidersFound?.call(providers, credential);
  }

  @override
  void onSignedIn(UserCredential credential) {
    setState(() {
      isLoading = false;
    });

    widget.onSignedIn?.call(credential);
  }

  @override
  void onError(Object error) {
    try {
      defaultOnAuthError(provider, error);
    } on Exception catch (err) {
      widget.onError?.call(err);
    }
  }

  @override
  void onCanceled() {
    setState(() {
      isLoading = false;
    });

    widget.onCancelled?.call();
  }

  @override
  void didUpdateWidget(covariant OAuthProviderButtonBase oldWidget) {
    if (oldWidget.isLoading != widget.isLoading) {
      isLoading = widget.isLoading;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  OAuthProvider get provider => widget.provider;
}

class _ButtonContent extends StatelessWidget {
  final double height;
  final String iconSrc;
  final double iconPadding;
  final String assetsPackage;
  final String label;
  final bool isLoading;
  final Color textColor;
  final double fontSize;
  final Widget loadingIndicator;
  final BorderRadius borderRadius;
  final Color borderColor;
  final Color iconBackgroundColor;

  const _ButtonContent({
    Key? key,
    required this.height,
    required this.iconSrc,
    required this.iconPadding,
    required this.assetsPackage,
    required this.label,
    required this.isLoading,
    required this.fontSize,
    required this.textColor,
    required this.loadingIndicator,
    required this.borderRadius,
    required this.borderColor,
    required this.iconBackgroundColor,
  }) : super(key: key);

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: fontSize,
      width: fontSize,
      child: loadingIndicator,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: EdgeInsets.all(iconPadding),
      child: SvgPicture.string(
        iconSrc,
        width: height,
        height: height,
      ),
    );

    if (label.isNotEmpty) {
      final content = isLoading
          ? _buildLoadingIndicator()
          : Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.1,
                color: textColor,
                fontSize: fontSize,
              ),
            );

      final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
      final topMargin = isCupertino ? (height - fontSize) / 2 : 0.0;

      child = Stack(
        children: [
          child,
          Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: EdgeInsets.only(top: topMargin),
              child: content,
            ),
          ),
        ],
      );
    } else if (isLoading) {
      child = _buildLoadingIndicator();
    }

    return child;
  }
}

class _MaterialForeground extends StatelessWidget {
  final VoidCallback onTap;

  const _MaterialForeground({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ButtonContainer extends StatelessWidget {
  final double margin;
  final double height;
  final double? width;
  final Color color;
  final BorderRadius borderRadius;
  final Widget child;

  const _ButtonContainer({
    Key? key,
    required this.margin,
    required this.height,
    required this.color,
    required this.borderRadius,
    required this.child,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutFlowAwarePadding(
      padding: EdgeInsets.all(margin),
      child: SizedBox(
        height: height,
        width: width,
        child: Material(
          color: color,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
