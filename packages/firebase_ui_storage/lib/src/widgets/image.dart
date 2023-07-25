// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart' show BlurHash;
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
            animationDuration ?? const Duration(milliseconds: 1000),
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

    /// Pre-loaded blur-hash string.
    /// If not specified – the blur-hash will be fetched from the image's
    /// metadata.
    String? value,
  }) = _BlurHashLoadingStateVariant;

  /// A default [CircularProgressIndicator] or [CupertinoActivityIndicator]
  /// will be used as a placeholder.
  factory LoadingStateVariant.loadingIndicator({
    double size,
    double strokeWidth,
    Color? color,
  }) = _LoadingIndicatorLoadingStateVariant;

  factory LoadingStateVariant.shimmer({
    Curve? curve,
    Duration? animationDuration,
    double? initialProgress,
  }) = _ShimmerLoadingStateVariant;

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
  final String? value;

  const _BlurHashLoadingStateVariant({
    Curve? curve,
    Duration? animationDuration,
    this.value,
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
          animationDuration: const Duration(milliseconds: 1000),
        );
}

class _ShimmerLoadingStateVariant extends LoadingStateVariant {
  final double? initialProgress;

  const _ShimmerLoadingStateVariant({
    super.curve = Curves.linear,
    super.animationDuration = const Duration(milliseconds: 800),
    this.initialProgress,
  });
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

class _StorageImageState extends State<StorageImage>
    with SingleTickerProviderStateMixin {
  late Future<String> downloadUrlFuture = widget.ref.getDownloadURL();

  LoadingStateVariant get loadingStateVariant => widget.loadingStateVariant;
  Reference get ref => widget.ref;

  late final ctrl = widget.opacity == null
      ? AnimationController(
          vsync: this,
          duration: loadingStateVariant.animationDuration,
        )
      : null;

  late final Animation<double> opacity = widget.opacity ??
      CurvedAnimation(
        parent: ctrl!,
        curve: loadingStateVariant.curve,
      );

  void maybeAnimate() {
    if (ctrl == null) return;
    if (ctrl!.isAnimating) return;
    if (ctrl!.value == 1.0) return;

    ctrl!.forward();
  }

  bool animationsCompleted = false;

  @override
  void initState() {
    super.initState();
    opacity.addStatusListener(_onOpacityStatus);
  }

  void _onOpacityStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (animationsCompleted) return;

    setState(() {
      animationsCompleted = true;
    });
  }

  GlobalKey placeholderKey = GlobalKey();

  Widget frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (animationsCompleted) {
      return child;
    }

    if (wasSynchronouslyLoaded || frame != null) {
      maybeAnimate();
    }

    if (loadingStateVariant is _SolidColorLoadingStateVariant) {
      final placeholder = _SolidColorLoadingStateVariantPlaceholder(
        key: placeholderKey,
        color: (loadingStateVariant as _SolidColorLoadingStateVariant).color,
        child: child,
      );
      return placeholder;
    }

    if (loadingStateVariant is _BlurHashLoadingStateVariant) {
      final placeholder = _BlurHashLoadingStateVariantPlaceholder(
        key: placeholderKey,
        ref: ref,
        value: (loadingStateVariant as _BlurHashLoadingStateVariant).value,
        curve: loadingStateVariant.curve,
        duration: loadingStateVariant.animationDuration,
        child: child,
      );

      return placeholder;
    }

    if (loadingStateVariant is _ShimmerLoadingStateVariant) {
      final _ShimmerLoadingStateVariant(
        :initialProgress,
      ) = loadingStateVariant as _ShimmerLoadingStateVariant;

      final placeholder = _ShimmerLoadingStateVariantPlaceholder(
        key: placeholderKey,
        curve: loadingStateVariant.curve,
        duration: loadingStateVariant.animationDuration,
        initialProgress: initialProgress ?? 0,
        showContent: frame != null,
        child: child,
      );

      return placeholder;
    }

    if (loadingStateVariant is _LoadingIndicatorLoadingStateVariant) {
      final config =
          loadingStateVariant as _LoadingIndicatorLoadingStateVariant;

      return Stack(
        key: placeholderKey,
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: child),
          if (frame == null)
            LoadingIndicator(
              size: config.size,
              borderWidth: config.strokeWidth,
              color: config.color,
            ),
        ],
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
            frameBuilder: widget.frameBuilder ?? frameBuilder,
            gaplessPlayback: widget.gaplessPlayback,
            headers: widget.headers,
            height: widget.height,
            isAntiAlias: widget.isAntiAlias,
            loadingBuilder: widget.loadingBuilder,
            matchTextDirection: widget.matchTextDirection,
            repeat: widget.repeat,
            opacity: opacity,
            semanticLabel: widget.semanticLabel,
            width: widget.width,
          );
        }

        return (widget.frameBuilder ?? frameBuilder).call(
          context,
          Container(),
          null,
          false,
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

  @override
  void dispose() {
    ctrl?.dispose();
    opacity.removeStatusListener(_onOpacityStatus);
    super.dispose();
  }
}

class _SolidColorLoadingStateVariantPlaceholder extends StatelessWidget {
  final Color? color;
  final Widget child;

  const _SolidColorLoadingStateVariantPlaceholder({
    super.key,
    required this.child,
    this.color,
  });

  Color resolveLoadingColor(BuildContext context) {
    if (color != null) {
      return color!;
    }

    return Theme.of(context).colorScheme.surfaceTint.withOpacity(0.12);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: resolveLoadingColor(context),
      child: child,
    );
  }
}

class _BlurHashLoadingStateVariantPlaceholder extends StatefulWidget {
  final Reference ref;
  final Widget child;
  final String? value;
  final Duration duration;
  final Curve curve;

  const _BlurHashLoadingStateVariantPlaceholder({
    super.key,
    required this.ref,
    required this.child,
    this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutExpo,
  });

  @override
  State<_BlurHashLoadingStateVariantPlaceholder> createState() =>
      _BlurHashLoadingStateVariantPlaceholderState();
}

class _BlurHashLoadingStateVariantPlaceholderState
    extends State<_BlurHashLoadingStateVariantPlaceholder>
    with SingleTickerProviderStateMixin {
  late FutureOr<String?> blurHash = loadHash();

  double opacity = 0.0;

  FutureOr<String?> loadHash() async {
    if (widget.value != null) return widget.value;

    return widget.ref
        .getMetadata()
        .then((value) => value.customMetadata?['blurHash']);
  }

  Widget buildContent(String hash) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: opacity,
            duration: widget.duration,
            curve: widget.curve,
            child: BlurHash(
              hash: hash,
              onDecoded: () {
                setState(() {
                  opacity = 1.0;
                });
              },
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (blurHash is Future<String?>) {
      return FutureBuilder(
        future: blurHash as Future<String?>,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final hash = snapshot.requireData;
          if (hash == null) return widget.child;

          return buildContent(hash);
        },
      );
    } else {
      final hash = blurHash as String;
      return buildContent(hash);
    }
  }

  @override
  void didUpdateWidget(_BlurHashLoadingStateVariantPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ref.fullPath != widget.ref.fullPath) {
      blurHash = loadHash();
      opacity = 0.0;
    }
  }
}

class _ShimmerLoadingStateVariantPlaceholder extends StatefulWidget {
  final Curve curve;
  final Duration duration;
  final Widget child;
  final double initialProgress;
  final bool showContent;

  const _ShimmerLoadingStateVariantPlaceholder({
    super.key,
    required this.curve,
    required this.duration,
    required this.child,
    required this.showContent,
    this.initialProgress = 0.0,
  });

  @override
  State<_ShimmerLoadingStateVariantPlaceholder> createState() =>
      __ShimmerLoadingStateVariantPlaceholderState();
}

class __ShimmerLoadingStateVariantPlaceholderState
    extends State<_ShimmerLoadingStateVariantPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.initialProgress,
  )..repeat();

  late final animation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: ctrl,
    curve: widget.curve,
  ));

  Alignment getAlignment(double animationProgress) {
    return Alignment(
      -2 + animationProgress * 4,
      -2 + animationProgress * 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Theme.of(context).colorScheme.surfaceTint.withOpacity(0.12);
    final b = Theme.of(context).colorScheme.surfaceTint.withOpacity(0.24);

    final (lighter, darker) = switch (Theme.of(context).brightness) {
      Brightness.light => (a, b),
      Brightness.dark => (b, a),
    };

    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, child) {
        final alignment = getAlignment(animation.value);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                darker,
                lighter,
                darker,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: getAlignment(animation.value),
              end: alignment + const Alignment(1, 1),
            ),
          ),
          child: child,
        );
      },
      child: widget.showContent ? widget.child : null,
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }
}
