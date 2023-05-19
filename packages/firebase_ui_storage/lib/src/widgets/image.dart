import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

abstract class LoadingStateVariant {
  const LoadingStateVariant({
    Curve? curve,
    Duration? animationDuration,
  })  : animationDuration =
            animationDuration ?? const Duration(milliseconds: 200),
        curve = curve ?? Curves.easeOutExpo;

  factory LoadingStateVariant.solidColor({
    Color? color,
    Curve? curve,
    Duration? animationDuration,
  }) = SolidColor;

  final Duration animationDuration;
  final Curve curve;
}

class SolidColor extends LoadingStateVariant {
  const SolidColor({
    this.color,
    Curve? curve,
    Duration? animationDuration,
  }) : super(curve: curve, animationDuration: animationDuration);

  final Color? color;
}

class StorageImage extends StatefulWidget {
  /// A reference to the image in Firebase Storage.
  final Reference ref;

  /// Decides what kind of placeholder should be rendered
  /// wuile the image is loading.
  final LoadingStateVariant loadingStateVariant;

  /// See [Image.errorBuilder]
  final Widget Function(
    BuildContext context,
    Object error, [
    StackTrace? stackTrace,
  ])? errorBuilder;

  /// See [Image.scale]
  final double scale;

  /// See [Image.alignment]
  final AlignmentGeometry alignment;

  /// See [Image.cacheHeight]
  final int? cacheHeight;

  /// See [Image.cacheWidth]
  final int? cacheWidth;

  /// See [Image.centerSlice]
  final Rect? centerSlice;

  /// See [Image.color]
  final Color? color;

  /// See [Image.colorBlendMode]
  final BlendMode? colorBlendMode;

  /// See [Image.excludeFromSemantics]
  final bool excludeFromSemantics;

  /// See [Image.filterQuality]
  final FilterQuality filterQuality;

  /// See [Image.fit]
  final BoxFit? fit;

  /// See [Image.frameBuilder]
  final ImageFrameBuilder? frameBuilder;

  /// See [Image.gaplessPlayback]
  final bool gaplessPlayback;

  /// See [Image.headers]
  final Map<String, String>? headers;

  /// See [Image.height]
  final double? height;

  /// See [Image.isAntiAlias]
  final bool isAntiAlias;

  /// See [Image.loadingBuilder]
  final ImageLoadingBuilder? loadingBuilder;

  /// See [Image.matchTextDirection]
  final bool matchTextDirection;

  /// See [Image.repeat]
  final ImageRepeat repeat;

  /// See [Image.opacity]
  final Animation<double>? opacity;

  /// See [Image.semanticLabel]
  final String? semanticLabel;

  /// See [Image.width]
  final double? width;

  const StorageImage({
    super.key,
    required this.ref,
    this.errorBuilder,
    this.scale = 1.0,
    this.alignment = Alignment.center,
    this.cacheHeight,
    this.cacheWidth,
    this.centerSlice,
    this.color,
    this.colorBlendMode,
    this.excludeFromSemantics = false,
    this.filterQuality = FilterQuality.low,
    this.fit,
    this.frameBuilder,
    this.gaplessPlayback = false,
    this.headers,
    this.height,
    this.isAntiAlias = false,
    this.loadingBuilder,
    this.matchTextDirection = false,
    this.repeat = ImageRepeat.noRepeat,
    this.opacity,
    this.semanticLabel,
    this.width,
    this.loadingStateVariant = const SolidColor(),
  });

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  late Future<String> downloadUrlFuture = widget.ref.getDownloadURL();

  Widget loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (widget.loadingStateVariant is SolidColor) {
      Widget placeholder = _SolidColorPlaceholder(
        animationDuration: widget.loadingStateVariant.animationDuration,
        curve: widget.loadingStateVariant.curve,
        color: (widget.loadingStateVariant as SolidColor).color,
        loadingProgress: loadingProgress,
        child: child,
      );
      return placeholder;
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: downloadUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final customError =
              widget.errorBuilder?.call(context, snapshot.error!);
          return customError ?? const SizedBox.shrink();
        }

        if (snapshot.hasData) {
          return Image.network(
            snapshot.data as String,
            scale: widget.scale,
            alignment: widget.alignment,
            cacheHeight: widget.cacheHeight,
            cacheWidth: widget.cacheWidth,
            centerSlice: widget.centerSlice,
            color: widget.color,
            colorBlendMode: widget.colorBlendMode,
            errorBuilder: widget.errorBuilder,
            excludeFromSemantics: widget.excludeFromSemantics,
            filterQuality: widget.filterQuality,
            fit: widget.fit,
            frameBuilder: widget.frameBuilder,
            gaplessPlayback: widget.gaplessPlayback,
            headers: widget.headers,
            height: widget.height,
            isAntiAlias: widget.isAntiAlias,
            loadingBuilder: widget.loadingBuilder ?? loadingBuilder,
            matchTextDirection: widget.matchTextDirection,
            repeat: widget.repeat,
            opacity: widget.opacity,
            semanticLabel: widget.semanticLabel,
            width: widget.width,
          );
        }

        return (widget.loadingBuilder ?? loadingBuilder).call(
          context,
          const SizedBox.shrink(),
          null,
        );
      },
    );
  }
}

class _SolidColorPlaceholder extends StatelessWidget {
  final Color? color;
  final Widget child;
  final Duration animationDuration;
  final Curve curve;
  final ImageChunkEvent? loadingProgress;

  const _SolidColorPlaceholder({
    required this.child,
    this.color,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutExpo,
    required this.loadingProgress,
  });

  Color resolveLoadingColor(BuildContext context) {
    if (color != null) {
      return color!;
    }

    return Theme.of(context).colorScheme.onSurface.withOpacity(0.12);
  }

  @override
  Widget build(BuildContext context) {
    var opacity = 0.0;

    if (loadingProgress != null && loadingProgress!.complete()) {
      opacity = 1.0;
    }

    return Container(
      color: resolveLoadingColor(context),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: animationDuration,
        curve: curve,
        child: child,
      ),
    );
  }
}

extension on ImageChunkEvent {
  bool complete() {
    return cumulativeBytesLoaded == expectedTotalBytes;
  }
}
