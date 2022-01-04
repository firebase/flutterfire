// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase.database')
library firebase.database_interop;

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    show PromiseJsImpl, Func1;
import 'package:firebase_database_web/src/interop/app_interop.dart';
import 'package:js/js.dart';

part 'data_snapshot_interop.dart';

part 'query_interop.dart';

part 'reference_interop.dart';

external void enableLogging([logger, bool persistent]);

// ignore: avoid_classes_with_only_static_members
/// A placeholder value for auto-populating the current timestamp
/// (time since the Unix epoch, in milliseconds) as determined
/// by the Firebase servers.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database#.ServerValue>.
@JS()
abstract class ServerValue {
  external static Object get TIMESTAMP;
}

@JS('Database')
abstract class DatabaseJsImpl {
  external AppJsImpl get app;

  external set app(AppJsImpl a);

  external void goOffline();

  external void goOnline();

  external void useEmulator(String host, int port);

  external ReferenceJsImpl ref([String? path]);

  external ReferenceJsImpl refFromURL(String url);
}

@JS('OnDisconnect')
abstract class OnDisconnectJsImpl {
  external PromiseJsImpl<void> cancel([void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> remove([void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> set(value, [void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> setWithPriority(
    value,
    priority, [
    void Function(dynamic) onComplete,
  ]);

  external PromiseJsImpl<void> update(
    values, [
    void Function(dynamic) onComplete,
  ]);
}

@JS('ThenableReference')
abstract class ThenableReferenceJsImpl extends ReferenceJsImpl
    implements PromiseJsImpl<ReferenceJsImpl> {
  @override
  external PromiseJsImpl<void> then([Func1? onResolve, Func1? onReject]);
}

@JS()
@anonymous
class TransactionJsImpl {
  external bool get committed;

  external DataSnapshotJsImpl get snapshot;

  external factory TransactionJsImpl({
    bool? committed,
    DataSnapshotJsImpl? snapshot,
  });
}
