// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

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

typedef SideBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

class ResponsivePage extends StatefulWidget {
  final Widget child;
  final TextDirection? desktopLayoutDirection;
  final SideBuilder? sideBuilder;
  final HeaderBuilder? headerBuilder;
  final double? headerMaxExtent;
  final double breakpoint;
  final int? contentFlex;
  final double? maxWidth;

  const ResponsivePage({
    Key? key,
    required this.child,
    this.desktopLayoutDirection,
    this.sideBuilder,
    this.headerBuilder,
    this.headerMaxExtent,
    this.breakpoint = 800,
    this.contentFlex,
    this.maxWidth,
  }) : super(key: key);

  @override
  State<ResponsivePage> createState() => _ResponsivePageState();
}

class _ResponsivePageState extends State<ResponsivePage> {
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
    final breakpoint = widget.breakpoint;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.biggest.width > breakpoint) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth ?? constraints.biggest.width,
              ),
              child: Row(
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
                    flex: widget.contentFlex ?? 1,
                    child: Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: breakpoint),
                              child: IntrinsicHeight(
                                child: widget.child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else if (widget.headerBuilder != null) {
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
                        maxExtent:
                            widget.headerMaxExtent ?? defaultHeaderImageHeight,
                        builder: widget.headerBuilder!,
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildListDelegate.fixed(
                      [widget.child],
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                widget.child,
              ],
            ),
          );
        }
      },
    );
  }
}
