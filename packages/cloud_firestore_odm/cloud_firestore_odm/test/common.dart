import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:flutter/foundation.dart';

class FakeCollectionReference<Value>
    extends QueryReference<FakeQuerySnapshot<Value>>
    implements FirestoreCollectionReference<FakeQuerySnapshot<Value>> {
  FakeCollectionReference(this.valueListenable);
  final ValueListenable<List<Value>> valueListenable;

  @override
  Future<FakeQuerySnapshot<Value>> get([GetOptions? options]) async {
    return FakeQuerySnapshot<Value>(
      valueListenable.value
          .map(FakeFirestoreQueryDocumentSnapshot.new)
          .toList(),
    );
  }

  @override
  CollectionReference<Object?> get reference => throw UnimplementedError();

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

  @override
  String get path => throw UnimplementedError();

  @override
  FirestoreDocumentReference<FirestoreDocumentSnapshot> doc([String? id]) {
    throw UnimplementedError();
  }

  @override
  QueryReference<FakeQuerySnapshot<Value>> limit(int limit) {
    throw UnimplementedError();
  }

  @override
  QueryReference<FakeQuerySnapshot<Value>> limitToLast(int limit) {
    throw UnimplementedError();
  }
}

class FakeQuerySnapshot<Value> extends FirestoreQuerySnapshot {
  FakeQuerySnapshot(this.docs);

  @override
  List<FirestoreDocumentChange<FirestoreQueryDocumentSnapshot>>
      get docChanges => throw UnimplementedError();

  @override
  final List<FakeFirestoreQueryDocumentSnapshot<Value>> docs;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  QuerySnapshot<Object?> get snapshot => throw UnimplementedError();
}

class FakeFirestoreQueryDocumentSnapshot<Value>
    extends FirestoreQueryDocumentSnapshot {
  FakeFirestoreQueryDocumentSnapshot(this.data);

  @override
  final Value data;

  @override
  FirestoreDocumentReference<FirestoreDocumentSnapshot> get reference =>
      throw UnimplementedError();

  @override
  QueryDocumentSnapshot<Object?> get snapshot => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
}

class FakeDocumentReference<Value>
    extends FirestoreDocumentReference<FakeDocumentSnapshot<Value>> {
  FakeDocumentReference(
    this.valueListenable, {
    this.errorListenable,
    this.emitCurrentValue = true,
  });

  final ValueListenable<Value> valueListenable;
  final ValueListenable<Object>? errorListenable;
  final bool emitCurrentValue;

  @override
  Future<FakeDocumentSnapshot<Value>> get([GetOptions? options]) async {
    return FakeDocumentSnapshot<Value>(valueListenable.value);
  }

  @override
  DocumentReference<Object?> get reference => throw UnimplementedError();

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

  @override
  Future<void> delete() => throw UnimplementedError();

  @override
  String get id => throw UnimplementedError();

  @override
  String get path => throw UnimplementedError();
}

class FakeDocumentSnapshot<Value> extends FirestoreDocumentSnapshot {
  FakeDocumentSnapshot(this.data);

  @override
  final Value data;

  @override
  FirestoreDocumentReference<FirestoreDocumentSnapshot> get reference =>
      throw UnimplementedError();

  @override
  DocumentSnapshot<Object?> get snapshot => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
}
