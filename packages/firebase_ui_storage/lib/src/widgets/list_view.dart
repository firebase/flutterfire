// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../paginated_loading_controller.dart';

Widget _defaultLoadingBuilder(BuildContext context) {
  return const Center(
    child: LoadingIndicator(
      size: 32,
      borderWidth: 2,
    ),
  );
}

/// A [ListView.builder] that automatically handles paginated loading from
/// [FirebaseStorage].
///
/// Example usage:
///
/// ```dart
/// StorageListView(
///   ref: storage.ref('images'),
///   itemBuilder: (context, ref) {
///     return AspectRatio(
///       aspectRatio: 1,
///       child: StorageImage(ref: ref),
///     );
///   },
///   loadingBuilder: (context) {
///     return const Center(
///       child: CircularProgressIndicator(),
///     );
///   },
///   errorBuilder: (context, error, controller) {
///     return Center(
///       child: Column(
///         mainAxisSize: MainAxisSize.min,
///         children: [
///           Text('Error: $error'),
///           TextButton(
///             onPressed: () => controller.load(),
///             child: const Text('Retry'),
///           ),
///         ],
///       ),
///     );
///   },
/// )
class StorageListView extends StatefulWidget {
  /// The [Reference] to list items from.
  /// If not provided, a [loadingController] must be created and passed.
  final Reference? ref;

  /// The number of items to load per page.
  /// Defaults to 50.
  final int pageSize;

  /// A builder that is called for the first page load.
  final Widget Function(BuildContext context) loadingBuilder;

  /// A builder that is called when an error occurs during page loading.
  final Widget Function(
    BuildContext context,
    Object? error,
    PaginatedLoadingController controller,
  )? errorBuilder;

  /// A builder that is called for each item in the list.
  final Widget Function(BuildContext context, Reference ref) itemBuilder;

  /// A controller that can be used to listen for all page loading states.
  ///
  /// If this is not provided, a new controller will be created with a given
  /// [ref] and [pageSize].
  final PaginatedLoadingController? loadingController;

  /// See [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// See [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// See [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// See [ScrollView.cacheExtent].
  final double? cacheExtent;

  /// See [ScrollView.clipBehavior].
  final Clip clipBehavior;

  /// See [ScrollView.controller].
  final ScrollController? controller;

  /// See [ScrollView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [SliverChildBuilderDelegate.findChildIndexCallback].
  final int? Function(Key key)? findChildIndexCallback;

  /// See [ListView.itemExtent].
  final double? itemExtent;

  /// See [ScrollView.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// See [ListView.padding].
  final EdgeInsetsGeometry? padding;

  /// See [ListView.prototypeItem].
  final Widget? prototypeItem;

  /// See [ScrollView.physics].
  final ScrollPhysics? physics;

  /// See [ScrollView.primary].
  final bool? primary;

  /// See [ScrollView.restorationId].
  final String? restorationId;

  /// See [ScrollView.reverse].
  final bool reverse;

  /// See [ScrollView.scrollDirection].
  final Axis scrollDirection;

  /// See [ListView.semanticChildCount].
  final int? semanticChildCount;

  /// See [ScrollView.shrinkWrap].
  final bool shrinkWrap;

  const StorageListView({
    super.key,
    required this.itemBuilder,
    this.ref,
    this.pageSize = 50,
    this.loadingBuilder = _defaultLoadingBuilder,
    this.errorBuilder,
    this.loadingController,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.findChildIndexCallback,
    this.itemExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.padding,
    this.prototypeItem,
    this.physics,
    this.primary,
    this.restorationId,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.semanticChildCount,
    this.shrinkWrap = false,
  }) : assert(
          ref != null || loadingController != null,
          'ref or loadingController must be provided',
        );

  @override
  State<StorageListView> createState() => _StorageListViewState();
}

class _StorageListViewState extends State<StorageListView> {
  late PaginatedLoadingController ctrl = widget.loadingController ??
      PaginatedLoadingController(
        ref: widget.ref!,
        pageSize: widget.pageSize,
      );

  @override
  void didUpdateWidget(covariant StorageListView oldWidget) {
    if (oldWidget.pageSize != widget.pageSize) {
      ctrl.pageSize = widget.pageSize;
    }

    if (oldWidget.ref != widget.ref) {
      ctrl = PaginatedLoadingController(
        ref: widget.ref!,
        pageSize: widget.pageSize,
      );
    }

    super.didUpdateWidget(oldWidget);
  }

  Widget listBuilder(BuildContext context, List<Reference> items) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (ctrl.shouldLoadNextPage(index)) {
          ctrl.load();
        }

        return widget.itemBuilder(context, items[index]);
      },
      itemCount: items.length,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      clipBehavior: widget.clipBehavior,
      controller: widget.controller,
      dragStartBehavior: widget.dragStartBehavior,
      findChildIndexCallback: widget.findChildIndexCallback,
      itemExtent: widget.itemExtent,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      padding: widget.padding,
      prototypeItem: widget.prototypeItem,
      physics: widget.physics,
      primary: widget.primary,
      restorationId: widget.restorationId,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      semanticChildCount: widget.semanticChildCount,
      shrinkWrap: widget.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        return switch (ctrl.state) {
          InitialPageLoading() => widget.loadingBuilder(context),
          PageLoadError(
            error: final error,
            items: final items,
          ) =>
            widget.errorBuilder != null
                ? widget.errorBuilder!(context, error, ctrl)
                : listBuilder(context, items ?? []),
          PageLoading(items: final items) => listBuilder(context, items),
          PageLoadComplete(items: final items) => listBuilder(context, items),
        };
      },
    );
  }
}
