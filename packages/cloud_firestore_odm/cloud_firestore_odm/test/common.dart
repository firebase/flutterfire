// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:flutter/foundation.dart';

// ignore: subtype_of_sealed_class
class _FakeQueryRef<Value> implements Query<Value> {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

class FakeCollectionReference<Value>
    extends FirestoreCollectionReference<Value, FakeQuerySnapshot<Value>> {
  FakeCollectionReference(this.valueListenable)
      : super($referenceWithoutCursor: _FakeQueryRef());

  @override
  CollectionReference<Value> get reference => throw UnimplementedError();

  final ValueListenable<List<Value>> valueListenable;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }

  @override
  Future<FakeQuerySnapshot<Value>> get([GetOptions? options]) async {
    return FakeQuerySnapshot<Value>(
      valueListenable.value
          .map(FakeFirestoreQueryDocumentSnapshot.new)
          .toList(),
    );
  }

  @override
  Stream<FakeQuerySnapshot<Value>> snapshots([GetOptions? options]) {
    late StreamController<FakeQuerySnapshot<Value>> controller;

    void listener() {
      controller.add(
        FakeQuerySnapshot<Value>(
          valueListenable.value
              .map(FakeFirestoreQueryDocumentSnapshot.new)
              .toList(),
        ),
      );
    }

    controller = StreamController(
      sync: true,
      onListen: () {
        valueListenable.addListener(listener);
        listener();
      },
      onCancel: () {
        valueListenable.removeListener(listener);
        controller.close();
      },
    );

    return controller.stream;
  }
}

class FakeQuerySnapshot<Value> extends FirestoreQuerySnapshot<Value,
    FakeFirestoreQueryDocumentSnapshot<Value>> {
  FakeQuerySnapshot(this.docs);

  @override
  final List<FakeFirestoreQueryDocumentSnapshot<Value>> docs;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

class FakeFirestoreQueryDocumentSnapshot<Value>
    extends FirestoreQueryDocumentSnapshot<Value> {
  FakeFirestoreQueryDocumentSnapshot(this.data);

  @override
  final Value data;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

class FakeDocumentReference<Value>
    extends FirestoreDocumentReference<Value, FakeDocumentSnapshot<Value>> {
  FakeDocumentReference(
    this.valueListenable, {
    this.errorListenable,
    this.emitCurrentValue = true,
  });

  final ValueListenable<Value> valueListenable;
  final ValueListenable<Object>? errorListenable;
  final bool emitCurrentValue;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }

  @override
  Future<FakeDocumentSnapshot<Value>> get([GetOptions? options]) async {
    return FakeDocumentSnapshot<Value>(valueListenable.value);
  }

  @override
  Stream<FakeDocumentSnapshot<Value>> snapshots([GetOptions? options]) {
    late StreamController<FakeDocumentSnapshot<Value>> controller;

    void listener() {
      controller.add(FakeDocumentSnapshot(valueListenable.value));
    }

    void onError() {
      controller.addError(errorListenable!.value);
    }

    controller = StreamController(
      sync: true,
      onListen: () {
        valueListenable.addListener(listener);
        errorListenable?.addListener(onError);
        if (emitCurrentValue) Future(listener);
      },
      onCancel: () {
        valueListenable.removeListener(listener);
        errorListenable?.removeListener(onError);
        controller.close();
      },
    );

    return controller.stream;
  }
}

class FakeDocumentSnapshot<Value> extends FirestoreDocumentSnapshot<Value> {
  FakeDocumentSnapshot(this.data);

  @override
  final Value data;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
