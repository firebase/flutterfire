import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

typedef ErrorBuilder = Widget Function(Exception e);
typedef DifferentProvidersFoundCallback = void Function(
  List<String> providers,
  AuthCredential? credential,
);

typedef SignedInCallback = void Function(UserCredential credential);

class OAuthProviderButton extends StatefulWidget {
  final String label;
  final double size;
  final double _padding;
  final Widget loadingIndicator;
  final AuthAction? action;
  final FirebaseAuth? auth;
  final void Function()? onTap;
  final OAuthProvider provider;

  final DifferentProvidersFoundCallback? onDifferentProvidersFound;

  final SignedInCallback? onSignedIn;

  final bool overrideDefaultTapAction;
  final bool isLoading;

  const OAuthProviderButton({
    Key? key,
    required this.label,
    required this.loadingIndicator,
    required this.provider,
    this.onTap,
    this.auth,
    this.action,
    this.onDifferentProvidersFound,
    this.onSignedIn,
    this.overrideDefaultTapAction = false,
    this.size = 19,
    this.isLoading = false,
  })  : assert(!overrideDefaultTapAction || onTap != null),
        _padding = size * 1.33 / 2,
        super(key: key);

  @override
  State<OAuthProviderButton> createState() => _OAuthProviderButtonState();
}

class _OAuthProviderButtonState extends State<OAuthProviderButton>
    with DefaultErrorHandlerMixin
    implements OAuthListener {
  double get _height => widget.size + widget._padding * 2;
  late bool isLoading = widget.isLoading;

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

    return Padding(
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
  void onBeforeCredentialLinked(AuthCredential credential) {
    setState(() {
      isLoading = true;
    });
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
  OAuthProvider get provider => widget.provider;
}

class _ButtonContent extends StatelessWidget {
  final double height;
  final String iconSrc;
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
      child: loadingIndicator,
      height: fontSize,
      width: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SvgPicture.asset(
      iconSrc,
      package: assetsPackage,
      width: height,
      height: height,
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
    return Padding(
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
