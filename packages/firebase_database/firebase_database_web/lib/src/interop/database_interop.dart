// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references, require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase.database')
library firebase.database_interop;

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_database_web/src/interop/app_interop.dart';
import 'package:js/js.dart';

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

  external ReferenceJsImpl ref([String? path]);

  external ReferenceJsImpl refFromURL(String url);
}

@JS('Reference')
abstract class ReferenceJsImpl extends QueryJsImpl {
  external String get key;

  external set key(String s);

  external ReferenceJsImpl get parent;

  external set parent(ReferenceJsImpl r);

  external ReferenceJsImpl get root;

  external set root(ReferenceJsImpl r);

  external ReferenceJsImpl child(String path);

  external OnDisconnectJsImpl onDisconnect();

  external ThenableReferenceJsImpl push([
    value,
    void Function(dynamic) onComplete,
  ]);

  external core_interop.PromiseJsImpl<void> remove(
      [void Function(dynamic) onComplete]);

  external core_interop.PromiseJsImpl<void> set(value,
      [void Function(dynamic) onComplete]);

  external core_interop.PromiseJsImpl<void> setPriority(
    priority, [
    void Function(dynamic) onComplete,
  ]);

  external core_interop.PromiseJsImpl<void> setWithPriority(
    newVal,
    newPriority, [
    void Function(dynamic) onComplete,
  ]);

  external core_interop.PromiseJsImpl<TransactionJsImpl> transaction(
    void Function(dynamic) transactionUpdate, [
    dynamic Function(Object, bool, DataSnapshotJsImpl) onComplete,
    bool applyLocally,
  ]);

  external core_interop.PromiseJsImpl<void> update(
    values, [
    void Function(dynamic) onComplete,
  ]);
}

@JS('Query')
abstract class QueryJsImpl {
  external ReferenceJsImpl get ref;

  external set ref(ReferenceJsImpl r);

  external QueryJsImpl endAt(value, [String key]);

  external QueryJsImpl equalTo(value, [String key]);

  external bool isEqual(QueryJsImpl other);

  external QueryJsImpl limitToFirst(int limit);

  external QueryJsImpl limitToLast(int limit);

  external void off([
    String eventType,
    dynamic Function(DataSnapshotJsImpl, [String]) callback,
    context,
  ]);

  external void Function() on(
    String eventType,
    dynamic Function(DataSnapshotJsImpl, [String]) callback, [
    cancelCallbackOrContext,
    context,
  ]);

  external core_interop.PromiseJsImpl<dynamic> once(
    String eventType, [
    dynamic Function(DataSnapshotJsImpl, [String]) callback,
    successCallback,
    failureCallbackOrContext,
    context,
  ]);

  external QueryJsImpl orderByChild(String path);

  external QueryJsImpl orderByKey();

  external QueryJsImpl orderByPriority();

  external QueryJsImpl orderByValue();

  external QueryJsImpl startAt(value, [String key]);

  external Object toJSON();

  @override
  external String toString();
}

@JS('DataSnapshot')
@anonymous
abstract class DataSnapshotJsImpl {
  external String get key;

  external set key(String s);

  external ReferenceJsImpl get ref;

  external set ref(ReferenceJsImpl r);

  external DataSnapshotJsImpl child(String path);

  external bool exists();

  external dynamic exportVal();

  external bool forEach(void Function(dynamic) action);

  external dynamic getPriority();

  external bool hasChild(String path);

  external bool hasChildren();

  external int numChildren();

  external dynamic val();

  external Object toJSON();
}

@JS('OnDisconnect')
abstract class OnDisconnectJsImpl {
  external core_interop.PromiseJsImpl<void> cancel(
      [void Function(dynamic) onComplete]);

  external core_interop.PromiseJsImpl<void> remove(
      [void Function(dynamic) onComplete]);

  external core_interop.PromiseJsImpl<void> set(value,
      [void Function(dynamic) onComplete]);

  external core_interop.PromiseJsImpl<void> setWithPriority(
    value,
    priority, [
    void Function(dynamic) onComplete,
  ]);

  external core_interop.PromiseJsImpl<void> update(
    values, [
    void Function(dynamic) onComplete,
  ]);
}

@JS('ThenableReference')
abstract class ThenableReferenceJsImpl extends ReferenceJsImpl
    implements core_interop.PromiseJsImpl<ReferenceJsImpl> {
  @override
  external core_interop.PromiseJsImpl<void> then(
      [core_interop.Func1? onResolve, core_interop.Func1? onReject]);
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
