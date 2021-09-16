// https://material.io/design/layout/responsive-layout-grid.html#breakpoints

import 'package:flutter/material.dart';

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
  double get margin => (size.width - bodyConstraints.maxWidth) / 2;

  double get gutterSize => _gutterSizes[deviceType]!;

  double get colSize => getColSize();

  double getColSize([double? gutterSize]) {
    final colsCount = _colsCount[deviceType]!;
    final guttersCount = colsCount - 1;
    final spaceWidth = (gutterSize ?? this.gutterSize) * guttersCount;
    final contentWidth = bodyConstraints.maxWidth - spaceWidth;

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

  BoxConstraints get bodyConstraints {
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
