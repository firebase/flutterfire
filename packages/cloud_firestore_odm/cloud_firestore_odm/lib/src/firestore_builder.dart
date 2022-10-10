// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'firestore_reference.dart';

/// {@macro cloud_firestore_odm.firestore_builder}
class FirestoreBuilder<Snapshot> extends StatefulWidget {
  /// {@template cloud_firestore_odm.firestore_builder}
  /// Listens to [ref] and build widgets out of the latest value emitted.
  ///
  /// This is a better solution than [StreamBuilder] for listening a Firestore
  /// reference, as [FirestoreBuilder] will cache the stream created with `ref.snapshots`,
  /// which could otherwise result in a billable operation.
  /// {@endtemplate}
  const FirestoreBuilder({
    Key? key,
    required this.ref,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// The listened reference
  final FirestoreListenable<Snapshot> ref;

  /// A function that builds widgets based on the latest snapshot from [ref].
  final Widget Function(
    BuildContext context,
    AsyncSnapshot<Snapshot> snapshot,
    Widget? child,
  ) builder;

  /// An optional child for performance optimisation when a part of the
  /// tree is not built based on [ref].
  final Widget? child;

  @override
  // ignore: library_private_types_in_public_api
  _FirestoreBuilderState<Snapshot> createState() =>
      _FirestoreBuilderState<Snapshot>();
}

class _FirestoreBuilderState<Snapshot>
    extends State<FirestoreBuilder<Snapshot>> {
  FirestoreReference? _streamCacheKey;
  late Stream<Object?> _streamCache;
  Stream<Object?> get _stream {
    final ref = _getReference(widget.ref);

    if (ref == _streamCacheKey) return _streamCache;

    _streamCacheKey = ref;
    return _streamCache = ref.snapshots();
  }

  var _lastSnapshot = const AsyncSnapshot<Object?>.nothing();
  Stream? _listenableCacheKey;
  VoidCallback? _removeListener;
  void _listenStream(Stream<Object?> stream) {
    if (stream == _listenableCacheKey) {
      return;
    }

    _removeListener?.call();
    _listenableCacheKey = stream;

    setSnapshot(_lastSnapshot.inState(ConnectionState.waiting));

    final sub = stream.listen(
      (event) {
        setSnapshot(AsyncSnapshot.withData(ConnectionState.active, event));
      },
      onError: (Object err, StackTrace stack) {
        setSnapshot(
          AsyncSnapshot.withError(ConnectionState.active, err, stack),
        );
      },
    );
    _removeListener = sub.cancel;
  }

  var _hasSelectedValue = false;
  late AsyncSnapshot<Snapshot> currentValue;

  void setSnapshot(AsyncSnapshot<Object?> snapshot) {
    _lastSnapshot = snapshot;

    final listenable = widget.ref;

    if (listenable is! FirestoreSelector<Object?, Snapshot>) {
      setState(() {
        currentValue = snapshot.whenData((val) => val as Snapshot);
      });
      return;
    }

    // ignore: invalid_use_of_protected_member
    final newSnapshot = snapshot.whenData(listenable.runSelector);

    if (!_hasSelectedValue ||
        !newSnapshot.hasData ||
        !currentValue.hasData ||
        newSnapshot.data != currentValue.data) {
      if (newSnapshot.connectionState == ConnectionState.active) {
        _hasSelectedValue = true;
      }
      setState(() => currentValue = newSnapshot);
    }
  }

  @override
  void initState() {
    super.initState();
    _listenStream(_stream);
  }

  @override
  void didUpdateWidget(covariant FirestoreBuilder<Snapshot> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasSelectedValue = false;
    _listenStream(_stream);
    setSnapshot(_lastSnapshot);
  }

  @override
  void dispose() {
    _removeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, currentValue, widget.child);
  }
}

FirestoreReference<Object?> _getReference(
  FirestoreListenable<Object?> listenable,
) {
  if (listenable is FirestoreReference<Object?>) {
    return listenable;
  } else if (listenable is FirestoreSelector<Object?, Object?>) {
    return listenable.reference;
  } else {
    throw UnsupportedError(
      'Unknown reference type: ${listenable.runtimeType}',
    );
  }
}

extension<T> on AsyncSnapshot<T> {
  AsyncSnapshot<Res> whenData<Res>(Res Function(T val) onData) {
    if (hasError) {
      return AsyncSnapshot<Res>.withError(connectionState, error!, stackTrace!);
    }
    if (hasData) {
      try {
        return AsyncSnapshot<Res>.withData(
          connectionState,
          onData(requireData),
        );
      } catch (error, stackTrace) {
        return AsyncSnapshot<Res>.withError(connectionState, error, stackTrace);
      }
    }

    return AsyncSnapshot<Res>.nothing().inState(connectionState);
  }
}
