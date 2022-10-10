// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupEmulator() async {
  await Firebase.initializeApp();

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}

Future<CollectionReference<T>> setupCollection<T>(
  CollectionReference<T> ref,
) async {
  final snapshot = await ref.get();

  await Future.wait([
    for (final doc in snapshot.docs) doc.reference.delete(),
  ]);

  return ref;
}

extension<T> on TypeMatcher<T> {
  TypeMatcher<T> applyHaving(
    String name,
    Object? Function(T value) selector,
    Object? value,
  ) {
    if (value != const _Sentinel()) {
      return having(selector, name, value);
    }

    return this;
  }
}

TypeMatcher<QueryDocumentSnapshot<T>> isQueryDocumentSnapshot<T>({
  Object? data = const _Sentinel(),
}) {
  var matcher = isA<QueryDocumentSnapshot<T>>();

  // ignore: join_return_with_assignment
  matcher = matcher.applyHaving('data', (value) => value.data(), data);

  return matcher;
}

TypeMatcher<FirestoreQueryBuilderSnapshot<T>> isQueryBuilderSnapshot<T>({
  Object? isFetching = const _Sentinel(),
  Object? isFetchingNextPage = const _Sentinel(),
  Object? error = const _Sentinel(),
  Object? stackTrace = const _Sentinel(),
  Object? docs = const _Sentinel(),
  Object? hasError = const _Sentinel(),
  Object? hasData = const _Sentinel(),
  Object? hasMore = const _Sentinel(),
}) {
  var matcher = isA<FirestoreQueryBuilderSnapshot<T>>();

  matcher = matcher.applyHaving(
    'isFetching',
    (value) => value.isFetching,
    isFetching,
  );
  matcher =
      matcher.applyHaving('hasError', (value) => value.hasError, hasError);
  matcher = matcher.applyHaving('hasData', (value) => value.hasData, hasData);
  matcher = matcher.applyHaving(
    'hasMore',
    (value) => value.hasMore,
    hasMore,
  );
  matcher = matcher.applyHaving(
    'isFetchingMore',
    (value) => value.isFetchingMore,
    isFetchingNextPage,
  );
  matcher = matcher.applyHaving('error', (value) => value.error, error);
  matcher = matcher.applyHaving(
    'stackTrace',
    (value) => value.stackTrace,
    stackTrace,
  );
  matcher = matcher.applyHaving('docs', (value) => value.docs, docs);

  return matcher;
}

class _Sentinel {
  const _Sentinel();
}
