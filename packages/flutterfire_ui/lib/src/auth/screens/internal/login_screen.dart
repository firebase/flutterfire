import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../../configs/provider_configuration.dart';
import '../../widgets/internal/keyboard_appearence_listener.dart';

typedef HeaderBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  double shrinkOffset,
);

typedef SideBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

const defaultHeaderImageHeight = 150.0;

class LoginImageSliverDelegate extends SliverPersistentHeaderDelegate {
  final HeaderBuilder builder;
  @override
  final double maxExtent;

  const LoginImageSliverDelegate({
    required this.builder,
    this.maxExtent = defaultHeaderImageHeight,
  }) : super();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(
        context,
        constraints,
        shrinkOffset / maxExtent,
      ),
    );
  }

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class LoginScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final AuthAction action;
  final List<ProviderConfiguration> providerConfigs;
  final HeaderBuilder? headerBuilder;
  final double? headerMaxExtent;
  final ButtonVariant? oauthButtonVariant;
  final SideBuilder? sideBuilder;
  final TextDirection? desktopLayoutDirection;
  final String? email;
  final bool? showAuthActionSwitch;

  const LoginScreen({
    Key? key,
    required this.action,
    required this.providerConfigs,
    this.auth,
    this.oauthButtonVariant,
    this.headerBuilder,
    this.headerMaxExtent = defaultHeaderImageHeight,
    this.sideBuilder,
    this.desktopLayoutDirection = TextDirection.ltr,
    this.email,
    this.showAuthActionSwitch,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ctrl = ScrollController();

  void _onKeyboardPositionChanged(double position) {
    if (!ctrl.hasClients) {
      return;
    }

    if (widget.headerBuilder == null) return;

    final max = widget.headerMaxExtent ?? defaultHeaderImageHeight;
    final ctrlPosition = position.clamp(0.0, max);
    ctrl.jumpTo(ctrlPosition);
  }

  @override
  Widget build(BuildContext context) {
    final loginContent = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: LoginView(
          action: widget.action,
          providerConfigs: widget.providerConfigs,
          oauthButtonVariant: widget.oauthButtonVariant,
          email: widget.email,
          showAuthActionSwitch: widget.showAuthActionSwitch,
        ),
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.biggest.width > 800) {
            return Row(
              textDirection: widget.desktopLayoutDirection,
              children: <Widget>[
                if (widget.sideBuilder != null)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return widget.sideBuilder!(context, constraints);
                      },
                    ),
                  ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Center(child: loginContent),
                    ],
                  ),
                )
              ],
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: KeyboardAppearenceListener(
                listener: _onKeyboardPositionChanged,
                child: CustomScrollView(
                  controller: ctrl,
                  slivers: [
                    if (widget.headerBuilder != null)
                      SliverPersistentHeader(
                        delegate: LoginImageSliverDelegate(
                          maxExtent: widget.headerMaxExtent ??
                              defaultHeaderImageHeight,
                          builder: widget.headerBuilder!,
                        ),
                      ),
                    SliverFillViewport(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Container(
                            alignment: Alignment.topCenter,
                            child: loginContent,
                          );
                        },
                        childCount: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
