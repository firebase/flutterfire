import 'package:firebase_ui/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../../configs/provider_configuration.dart';
import '../../widgets/internal/keyboard_appearence_listener.dart';

typedef HeaderBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  double shrinkOffset,
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

  const LoginScreen({
    Key? key,
    required this.action,
    required this.providerConfigs,
    this.auth,
    this.headerBuilder,
    this.headerMaxExtent = defaultHeaderImageHeight,
    this.oauthButtonVariant,
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

    final max = widget.headerMaxExtent ?? defaultHeaderImageHeight;
    final ctrlPosition = position.clamp(0.0, max);
    ctrl.jumpTo(ctrlPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: KeyboardAppearenceListener(
          listener: _onKeyboardPositionChanged,
          child: CustomScrollView(
            controller: ctrl,
            slivers: [
              if (widget.headerBuilder != null)
                SliverPersistentHeader(
                  delegate: LoginImageSliverDelegate(
                    maxExtent:
                        widget.headerMaxExtent ?? defaultHeaderImageHeight,
                    builder: widget.headerBuilder!,
                  ),
                ),
              SliverFillViewport(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(30),
                      child: LoginView(
                        action: widget.action,
                        providerConfigs: widget.providerConfigs,
                        headerBuilder: widget.headerBuilder,
                        headerMaxExtent: widget.headerMaxExtent,
                        oauthButtonVariant: widget.oauthButtonVariant,
                      ),
                    );
                  },
                  childCount: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
