// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/widgets.dart';

import 'default_loading_indicator.dart';

Widget _defaultLoadingBuilder(BuildContext context) {
  return const DefaultLoadingIndicator();
}

class StorageGridView extends StatefulWidget {
  /// The [Reference] to list items from.
  /// If not provided, a [loadingController] must be created and passed.
  final Reference? ref;

  final PaginatedLoadingController? loadingController;

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

  /// See [SliverGridDelegate].
  final SliverGridDelegate gridDelegate;

  const StorageGridView({
    super.key,
    this.ref,
    this.loadingController,
    this.pageSize = 50,
    this.loadingBuilder = _defaultLoadingBuilder,
    this.errorBuilder,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
    ),
    required this.itemBuilder,
  }) : assert(
          ref != null || loadingController != null,
          'ref or loadingController must be provided',
        );

  @override
  State<StorageGridView> createState() => _StorageGridViewState();
}

class _StorageGridViewState extends State<StorageGridView> {
  late PaginatedLoadingController ctrl = widget.loadingController ??
      PaginatedLoadingController(
        ref: widget.ref!,
        pageSize: widget.pageSize,
      );

  Widget gridBuilder(BuildContext context, List<Reference> items) {
    return GridView.builder(
      gridDelegate: widget.gridDelegate,
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (ctrl.shouldLoadNextPage(index)) {
          ctrl.load();
        }

        return widget.itemBuilder(context, items[index]);
      },
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
                : gridBuilder(context, items ?? []),
          PageLoading(items: final items) => gridBuilder(context, items),
          PageLoadComplete(items: final items) => gridBuilder(context, items),
        };
      },
    );
  }
}
