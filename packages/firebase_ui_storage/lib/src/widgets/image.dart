import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';

/// Describes what kind of placholder should be used while the image is
/// loading.
abstract class LoadingStateVariant {
  const LoadingStateVariant({
    /// {@macro ui.storage.image.loadingStateVariant.curve}
    Curve? curve,

    /// {@macro ui.storage.image.loadingStateVariant.animationDuration}
    Duration? animationDuration,
  })  : animationDuration =
            animationDuration ?? const Duration(milliseconds: 200),
        curve = curve ?? Curves.easeOutExpo;

  /// A solid color placeholder.
  factory LoadingStateVariant.solidColor({
    /// A color of the container to be used as a placeholder.
    Color? color,

    /// {@macro ui.storage.image.loadingStateVariant.curve}
    Curve? curve,

    /// {@macro ui.storage.image.loadingStateVariant.animationDuration}
    Duration? animationDuration,
  }) = _SolidColorLoadingStateVariant;

  /// A placeholder generated from a blur hash.
  /// See https://pub.dev/packages/flutter_blurhash.
  ///
  /// Requires a "blurHash" key to be present on the image's metadata.
  factory LoadingStateVariant.blurHash({
    /// {@macro ui.storage.image.loadingStateVariant.curve}
    Curve? curve,

    /// {@macro ui.storage.image.loadingStateVariant.animationDuration}
    Duration? animationDuration,
  }) = _BlurHashLoadingStateVariant;

  /// A default [CircularProgressIndicator] or [CupertinoActivityIndicator]
  /// will be used as a placeholder.
  factory LoadingStateVariant.loadingIndicator({
    double size,
    double strokeWidth,
    Color? color,
  }) = _LoadingIndicatorLoadingStateVariant;

  /// {@template ui.storage.image.loadingStateVariant.animationDuration}
  /// The duration of the transtion between loading placeholder and the actual
  /// image.
  /// {@endtemplate}
  final Duration animationDuration;

  /// {@template ui.storage.image.loadingStateVariant.curve}
  /// The curve of the transtion between loading placeholder and the actual
  /// image.
  /// {@endtemplate}
  final Curve curve;
}

class _SolidColorLoadingStateVariant extends LoadingStateVariant {
  const _SolidColorLoadingStateVariant({
    this.color,
    Curve? curve,
    Duration? animationDuration,
  }) : super(curve: curve, animationDuration: animationDuration);

  final Color? color;
}

class _BlurHashLoadingStateVariant extends LoadingStateVariant {
  const _BlurHashLoadingStateVariant({
    Curve? curve,
    Duration? animationDuration,
  }) : super(curve: curve, animationDuration: animationDuration);
}

class _LoadingIndicatorLoadingStateVariant extends LoadingStateVariant {
  final double size;
  final double strokeWidth;
  final Color? color;

  const _LoadingIndicatorLoadingStateVariant({
    this.size = 32,
    this.strokeWidth = 2,
    this.color,
  }) : super(
          curve: Curves.easeOutExpo,
          animationDuration: const Duration(milliseconds: 200),
        );
}

/// A widget that downloads and displays an image from Firebase Storage.
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

  /// See [NetworkImage.scale]
  final double scale;

  /// See [Image.alignment]
  final AlignmentGeometry alignment;

  /// See [Image.network] docs
  final int? cacheHeight;

  /// See [Image.network] docs
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
    this.loadingStateVariant = const _SolidColorLoadingStateVariant(),
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
    if (widget.loadingStateVariant is _SolidColorLoadingStateVariant) {
      Widget placeholder = _SolidColorLoadingStateVariantPlaceholder(
        animationDuration: widget.loadingStateVariant.animationDuration,
        curve: widget.loadingStateVariant.curve,
        color: (widget.loadingStateVariant as _SolidColorLoadingStateVariant)
            .color,
        loadingProgress: loadingProgress,
        child: child,
      );
      return placeholder;
    } else if (widget.loadingStateVariant is _BlurHashLoadingStateVariant) {
      Widget placeholder = _BlurHashLoadingStateVariantPlaceholder(
        ref: widget.ref,
        animationDuration: widget.loadingStateVariant.animationDuration,
        curve: widget.loadingStateVariant.curve,
        loadingProgress: loadingProgress,
        child: child,
      );
      return placeholder;
    } else if (widget.loadingStateVariant
        is _LoadingIndicatorLoadingStateVariant) {
      final config =
          widget.loadingStateVariant as _LoadingIndicatorLoadingStateVariant;

      return LoadingIndicator(
        borderWidth: config.strokeWidth,
        size: config.size,
        color: config.color,
      );
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

  @override
  void didUpdateWidget(StorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ref.fullPath != widget.ref.fullPath) {
      downloadUrlFuture = widget.ref.getDownloadURL();
    }
  }
}

class _PlaceholderTransition extends StatelessWidget {
  final Widget child;
  final Duration animationDuration;
  final Curve curve;
  final ImageChunkEvent? loadingProgress;

  const _PlaceholderTransition({
    required this.animationDuration,
    required this.curve,
    this.loadingProgress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var opacity = 0.0;

    if (loadingProgress != null && loadingProgress!.complete()) {
      opacity = 1.0;
    }

    return AnimatedOpacity(
      opacity: opacity,
      duration: animationDuration,
      curve: curve,
    );
  }
}

class _SolidColorLoadingStateVariantPlaceholder extends StatelessWidget {
  final Color? color;
  final Widget child;
  final Duration animationDuration;
  final Curve curve;
  final ImageChunkEvent? loadingProgress;

  const _SolidColorLoadingStateVariantPlaceholder({
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
    return Container(
      color: resolveLoadingColor(context),
      child: _PlaceholderTransition(
        loadingProgress: loadingProgress,
        animationDuration: animationDuration,
        curve: curve,
        child: child,
      ),
    );
  }
}

class _BlurHashLoadingStateVariantPlaceholder extends StatefulWidget {
  final Reference ref;
  final Duration animationDuration;
  final Curve curve;
  final ImageChunkEvent? loadingProgress;
  final Widget child;

  const _BlurHashLoadingStateVariantPlaceholder({
    required this.ref,
    required this.animationDuration,
    required this.curve,
    this.loadingProgress,
    required this.child,
  });

  @override
  State<_BlurHashLoadingStateVariantPlaceholder> createState() =>
      _BlurHashLoadingStateVariantPlaceholderState();
}

class _BlurHashLoadingStateVariantPlaceholderState
    extends State<_BlurHashLoadingStateVariantPlaceholder> {
  late Future<FullMetadata> metaDataFuture = widget.ref.getMetadata();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: metaDataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final metadata = snapshot.requireData;

        if (metadata.customMetadata == null ||
            !metadata.customMetadata!.containsKey('blurHash')) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            BlurHash(hash: metadata.customMetadata!['blurHash']!),
            _PlaceholderTransition(
              loadingProgress: widget.loadingProgress,
              animationDuration: widget.animationDuration,
              curve: widget.curve,
              child: widget.child,
            ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(_BlurHashLoadingStateVariantPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ref.fullPath != widget.ref.fullPath) {
      metaDataFuture = widget.ref.getMetadata();
    }
  }
}

extension on ImageChunkEvent {
  bool complete() {
    return cumulativeBytesLoaded == expectedTotalBytes;
  }
}
