// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../../widgets/internal/keyboard_appearence_listener.dart';

/// {@template ui.auth.screens.responsive_page.header_builder}
/// A builder that builds the contents of the header.
/// Used only on mobile platforms.
/// {@endtemplate}
typedef HeaderBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  double shrinkOffset,
);

const defaultHeaderImageHeight = 150.0;

class HeaderImageSliverDelegate extends SliverPersistentHeaderDelegate {
  final HeaderBuilder builder;
  @override
  final double maxExtent;

  const HeaderImageSliverDelegate({
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

/// {@template ui.auth.screens.responsive_page.side_builder}
/// A builder that builds a contents of a page displayed on a side of
/// of the main authentication related UI.
///
/// Used only on desktop platforms.
/// {@endtemplate}
typedef SideBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

class ResponsivePage extends StatefulWidget {
  /// Main content of the page
  final Widget child;

  /// {@template ui.auth.screens.responsive_page.desktop_layout_direction}
  /// A direction of the desktop layout.
  /// [TextDirection.ltr] indicates that side content is built on the left, and
  /// the child is placed on the right. The order is reversed when
  /// [TextDirection.rtl] is used.
  /// {@endtemplate}
  final TextDirection? desktopLayoutDirection;

  /// {@macro ui.auth.screens.responsive_page.side_builder}
  final SideBuilder? sideBuilder;

  /// {@macro ui.auth.screens.responsive_page.header_builder}
  final HeaderBuilder? headerBuilder;

  /// {@template ui.auth.screens.responsive_page.header_max_extent}
  /// The maximum height of the header.
  /// {@endtemplate}
  final double? headerMaxExtent;

  /// {@template ui.auth.screens.responsive_page.breakpoint}
  /// Min width of the viewport for desktop layout. If the available width is
  /// less than this value, a mobile layout is used.
  /// {@endtemplate}
  /// {@macro ui.auth.screens.responsive_page.breakpoint}
  final double breakpoint;

  /// {@template ui.auth.screens.responsive_page.content_flex}
  /// A flex value of the [Expanded] that wraps the child on desktop.
  /// {@endtemplate}
  final int? contentFlex;

  /// {@template ui.auth.screens.responsive_page.max_width}
  /// A max width of the page on desktop. If the available width is greater than
  /// this value, the content is centered and horizontal paddings are added.
  /// {@endtemplate}
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
  final paddingListenable = ValueNotifier<double>(0);
  final key = GlobalKey();

  void _onKeyboardPositionChanged(double position) {
    if (!ctrl.hasClients) {
      return;
    }

    if (widget.headerBuilder == null) return;

    paddingListenable.value = position;

    final max = widget.headerMaxExtent ?? defaultHeaderImageHeight;
    final ctrlPosition = position.clamp(0.0, max);
    ctrl.jumpTo(ctrlPosition);
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = widget.breakpoint;

    final content = KeyedSubtree(
      key: key,
      child: widget.child,
    );

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
                              child: content,
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
                      delegate: HeaderImageSliverDelegate(
                        maxExtent:
                            widget.headerMaxExtent ?? defaultHeaderImageHeight,
                        builder: widget.headerBuilder!,
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildListDelegate.fixed(
                      [
                        content,
                        ValueListenableBuilder<double>(
                          valueListenable: paddingListenable,
                          builder: (context, value, _) {
                            return SizedBox(height: value);
                          },
                        ),
                      ],
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
                content,
              ],
            ),
          );
        }
      },
    );
  }
}
