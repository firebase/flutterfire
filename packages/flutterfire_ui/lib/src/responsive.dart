// https://material.io/design/layout/responsive-layout-grid.html#breakpoTs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DeviceType {
  phone,
  phablet,
  tablet,
  laptop,
  desktop,
}

// TODO(@lesnitsky): scaling
const _margins = <DeviceType, double>{
  DeviceType.phone: 16.0,
  DeviceType.phablet: 32.0,
  DeviceType.laptop: 200.0,
};

const _colsCount = <DeviceType, int>{
  DeviceType.phone: 4,
  DeviceType.phablet: 8,
  DeviceType.tablet: 12,
  DeviceType.laptop: 12,
  DeviceType.desktop: 12,
};

const _gutterSizes = <DeviceType, double>{
  DeviceType.phone: 16,
  DeviceType.phablet: 16,
  DeviceType.tablet: 24,
  DeviceType.laptop: 24,
  DeviceType.desktop: 32,
};

extension Responsive on MediaQueryData {
  DeviceType get deviceType {
    final width = size.width;

    if (width <= 599) return DeviceType.phone;
    if (width <= 904) return DeviceType.phablet;
    if (width <= 1239) return DeviceType.tablet;
    if (width <= 1440) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  double get _margin => _margins[deviceType]!;
  double get margin => (size.width - bodyConstraTs.maxWidth) / 2;

  double get gutterSize => _gutterSizes[deviceType]!;

  double get colSize => getColSize();

  double getColSize([double? gutterSize]) {
    final colsCount = _colsCount[deviceType]!;
    final guttersCount = colsCount - 1;
    final spaceWidth = (gutterSize ?? this.gutterSize) * guttersCount;
    final contentWidth = bodyConstraTs.maxWidth - spaceWidth;

    return contentWidth / colsCount;
  }

  double widthFor({required int cols, double? gutterSize}) {
    final guttersCount = cols - 1;
    final _gutterSize = gutterSize ?? this.gutterSize;

    final innerGuttersWidth = guttersCount * _gutterSize;

    return getColSize(gutterSize) * cols + innerGuttersWidth;
  }

  BoxConstraints constraintsFor({required int cols, double? gutterSize}) {
    return BoxConstraints(
      maxWidth: widthFor(
        cols: cols,
        gutterSize: gutterSize,
      ),
    );
  }

  int get maxColsCount => _colsCount[deviceType]!;

  BoxConstraints get bodyConstraTs {
    switch (deviceType) {
      case DeviceType.phone:
      case DeviceType.phablet:
        return BoxConstraints(maxWidth: size.width - _margin * 2);
      case DeviceType.tablet:
        return const BoxConstraints(maxWidth: 840);
      case DeviceType.laptop:
        return BoxConstraints(maxWidth: size.width - _margin * 2);
      case DeviceType.desktop:
        return const BoxConstraints(maxWidth: 1040);
    }
  }
}

class Body extends StatelessWidget {
  final Widget child;
  const Body({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.margin),
      child: child,
    );
  }
}

class ResponsiveGridOverlay extends StatefulWidget {
  final bool enabled;
  final Widget? child;
  const ResponsiveGridOverlay({Key? key, this.child, this.enabled = false})
      : super(key: key);

  @override
  State<ResponsiveGridOverlay> createState() => _ResponsiveGridOverlayState();
}

class _ResponsiveGridOverlayState extends State<ResponsiveGridOverlay> {
  late var overlayVisible = widget.enabled;

  @override
  void initState() {
    if (!kReleaseMode) _bindShortcutListener();
    super.initState();
  }

  void _bindShortcutListener() {
    RawKeyboard.instance.addListener((value) {
      if (value is RawKeyDownEvent &&
          value.logicalKey == LogicalKeyboardKey.keyG &&
          value.isControlPressed) {
        setState(() {
          overlayVisible = !overlayVisible;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (overlayVisible)
          const IgnorePointer(
            ignoring: true,
            child: Body(child: _ResponsiveGrid()),
          ),
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...List.generate(
          mq.maxColsCount,
          (_) => Container(
            width: mq.colSize,
            color: Colors.pink.withAlpha(50),
          ),
        ),
      ],
    );
  }
}

abstract class Gutter extends StatelessWidget {
  const Gutter({Key? key}) : super(key: key);

  const factory Gutter.vertical() = _VerticalGutter;
  const factory Gutter.horizontal() = _HorizontalGutter;

  Size getGutterSize(MediaQueryData mq);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = getGutterSize(mq);
    return SizedBox(width: size.width, height: size.height);
  }
}

class _VerticalGutter extends Gutter {
  const _VerticalGutter();

  @override
  Size getGutterSize(MediaQueryData mq) {
    return Size(mq.gutterSize, double.infinity);
  }
}

class _HorizontalGutter extends Gutter {
  const _HorizontalGutter();

  @override
  Size getGutterSize(MediaQueryData mq) {
    return Size(double.infinity, mq.gutterSize);
  }
}

class ResponsiveValue<T> {
  final T phone;
  final T phablet;
  final T tablet;
  final T laptop;
  final T desktop;

  ResponsiveValue({
    required this.phone,
    required this.phablet,
    required this.tablet,
    required this.laptop,
    required this.desktop,
  });

  T resolve(BuildContext context) {
    final mq = MediaQuery.of(context);
    switch (mq.deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.phablet:
        return phablet;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.laptop:
        return laptop;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

class ColWidth extends ResponsiveValue<int> {
  ColWidth({
    required int phone,
    required int phablet,
    required int tablet,
    required int laptop,
    required int desktop,
  }) : super(
          phone: phone,
          phablet: phablet,
          tablet: tablet,
          laptop: laptop,
          desktop: desktop,
        );

  static expand() {
    return ColWidth(
      phone: _colsCount[DeviceType.phone]!,
      phablet: _colsCount[DeviceType.phablet]!,
      tablet: _colsCount[DeviceType.tablet]!,
      laptop: _colsCount[DeviceType.laptop]!,
      desktop: _colsCount[DeviceType.desktop]!,
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final ColWidth colWidth;
  const ResponsiveContainer({
    Key? key,
    required this.child,
    required this.colWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cols = colWidth.resolve(context);
    final constraints = MediaQuery.of(context).constraintsFor(cols: cols);

    return ConstrainedBox(
      constraints: constraints,
      child: child,
    );
  }
}
