import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter_svg/svg.dart';

import '../../auth_controller.dart';
import '../../auth_flow_builder.dart';
import '../../auth_state.dart';
import '../oauth_flow.dart';
import '../oauth_providers.dart';
import '../provider_resolvers.dart';
import 'oauth_provider_button_style.dart';

typedef ErrorCallback = void Function(Exception e);

abstract class ProviderButtonFlowFactoryWidget<T extends StatefulWidget>
    extends StatefulWidget {
  const ProviderButtonFlowFactoryWidget({Key? key}) : super(key: key);

  OAuthFlow createFlow(T widget);
  Widget get child;

  @override
  _ProviderButtonFlowFactoryWidgetState createState() =>
      _ProviderButtonFlowFactoryWidgetState();
}

class _ProviderButtonFlowFactoryWidgetState
    extends State<ProviderButtonFlowFactoryWidget> {
  late final flow = widget.createFlow(widget);

  @override
  Widget build(BuildContext context) {
    return ProviderButtonContainer(
      flow: flow,
      child: widget.child,
    );
  }
}

class ProviderButtonContainer extends StatelessWidget {
  final Widget child;
  final OAuthFlow flow;
  final ErrorCallback? onError;

  const ProviderButtonContainer({
    Key? key,
    this.onError,
    required this.flow,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<OAuthController>(
      flow: flow,
      listener: (prevState, state, controller) {
        if (state is AuthFailed) {
          onError?.call(state.exception);
        }
      },
      child: child,
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double borderWidth;
  final OAuthProviderButtonStyle style;

  const LoadingIndicator({
    Key? key,
    required this.size,
    required this.borderWidth,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: borderWidth * 2,
          valueColor: AlwaysStoppedAnimation<Color>(style.color),
        ),
      ),
    );
  }
}

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
    final ctrl = AuthController.ofType<OAuthController>(context);
    ctrl.signInWithProvider();
  }

  @override
  Widget build(BuildContext context) {
    final style = buttonStyle<T>().withBrightness(Theme.of(context).brightness);

    final margin = (size + _padding * 2) / 10;
    final borderRadius = size / 3;
    const borderWidth = 1.0;
    final iconBorderRadius = borderRadius - borderWidth;

    bool isLoading = AuthState.of(context) is SigningIn;

    final content = isLoading
        ? const SizedBox.shrink()
        : Text(
            buttonLabelForProvider<T>(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.1,
              color: style.color,
              fontSize: size,
            ),
          );

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
                child: SizedBox(
                  height: _height,
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
                      Expanded(child: content),
                    ],
                  ),
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
                  if (isLoading) return;
                  signIn(context);
                },
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: LoadingIndicator(
                size: size,
                borderWidth: borderWidth,
                style: style,
              ),
            ),
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
    bool isLoading = AuthState.of(context) is SigningIn;

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
            child: isLoading
                ? LoadingIndicator(
                    borderWidth: 1,
                    size: size / 2,
                    style: style,
                  )
                : SvgPicture.asset(
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
