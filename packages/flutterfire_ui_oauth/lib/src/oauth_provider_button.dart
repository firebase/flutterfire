import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterfire_ui_oauth/flutterfire_ui_oauth.dart';

typedef CredentialReceivedCallback = void Function(
  OAuthCredential credential,
);

typedef ErrorBuilder = Widget Function(Exception e);

class OAuthProviderButton extends StatefulWidget {
  const factory OAuthProviderButton.icon({
    required ThemedOAuthProviderButtonStyle style,
    required String label,
    required double size,
    required Widget loadingIndicator,
    required Future<void> Function() onTap,
  }) = OAuthProviderIconButton;

  final ThemedOAuthProviderButtonStyle style;
  final String label;
  final double size;
  final double _padding;
  final Widget loadingIndicator;
  final Future<void> Function() onTap;

  const OAuthProviderButton({
    Key? key,
    required this.style,
    required this.label,
    required this.onTap,
    required this.loadingIndicator,
    this.size = 19,
  })  : _padding = size * 1.33 / 2,
        super(key: key);

  @override
  State<OAuthProviderButton> createState() => _OAuthProviderButtonState();
}

class _OAuthProviderButtonState extends State<OAuthProviderButton> {
  double get _height => widget.size + widget._padding * 2;
  bool isLoading = false;

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
            onPressed: () => _signIn(),
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

  Future<void> _signIn() async {
    try {
      setState(() {
        isLoading = true;
      });
      await widget.onTap();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

    final style = widget.style.withBrightness(brightness);
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
}

class OAuthProviderIconButton extends OAuthProviderButton {
  const OAuthProviderIconButton({
    Key? key,
    required ThemedOAuthProviderButtonStyle style,
    required Future<void> Function() onTap,
    required Widget loadingIndicator,
    required String label,
    double size = 19,
  }) : super(
          key: key,
          style: style,
          label: '',
          size: size,
          onTap: onTap,
          loadingIndicator: loadingIndicator,
        );
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
