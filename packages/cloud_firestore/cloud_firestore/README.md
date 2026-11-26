[<img src="https://raw.githubusercontent.com/firebase/flutterfire/main/.github/images/flutter_favorite.png" width="200" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

# Cloud Firestore Plugin for Flutter

A Flutter plugin to use the [Cloud Firestore API](https://firebase.google.com/docs/firestore/).

To learn more about Firebase Cloud Firestore, please visit the [Firebase website](https://firebase.google.com/products/firestore)

[![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore)

## Getting Started

To get started with Cloud Firestore for Flutter, please [see the documentation](https://firebase.google.com/docs/firestore/quickstart).

## Usage

To use this plugin, please visit the [Firestore Usage documentation](https://firebase.google.com/docs/firestore/manage-data/add-data)

### Using Cloud Firestore with isolates

Cloud Firestore relies on `EventChannel` for streaming and callback-driven APIs:

- `DocumentReference.snapshots()`, `Query.snapshots()`, and `CollectionReference.snapshots()`
- `FirebaseFirestore.snapshotsInSync()`
- `FirebaseFirestore.runTransaction()`
- `FirebaseFirestore.loadBundle()`

Flutter's `BackgroundIsolateBinaryMessenger` only supports Dart-to-host messages and does not support host-to-Dart handlers (`BinaryMessenger.setMessageHandler`, tracked in [flutter/flutter#119207](https://github.com/flutter/flutter/issues/119207)). Listening to an `EventChannel`-backed stream (`snapshots()`, `snapshotsInSync()`, or `loadBundle().stream`) or running `runTransaction()` from a background isolate fails with an `UnsupportedError`.

One-off Dart-to-host calls (such as `get()`, `set()`, `update()`, `delete()`, `WriteBatch.commit()`, and aggregate queries) do not use `EventChannel`. However, each Dart isolate maintains its own `firebase_core` app registry; calling `Firebase.initializeApp()` from a background isolate while Firebase is already initialized on the root isolate triggers native core reinitialization (`didReinitializeFirebaseCore`) on native platforms. On Android, iOS, and macOS, the Cloud Firestore plugin handles that callback by cancelling active snapshot listeners and terminating existing `FirebaseFirestore` instances on the root isolate (the Windows implementation does not register a reinitialization handler). On web, Dart isolates and `BackgroundIsolateBinaryMessenger` are not supported.

#### Recommended pattern

Keep Firestore reads, writes, and listeners on the root isolate, convert the document fields you need into plain Dart values (or your own immutable model), and send only that data to `Isolate.run()` or `compute()` for CPU-heavy work:

```dart
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, Object?>>> loadProducts() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('products').get();

  final rawProducts = snapshot.docs.map((doc) {
    final data = doc.data();
    final location = data['location'] as GeoPoint?;
    final updatedAt = data['updatedAt'] as Timestamp?;
    final category = data['category'] as DocumentReference?;

    return <String, Object?>{
      'id': doc.id,
      'price': (data['price'] as num?)?.toDouble() ?? 0.0,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'updatedAtMs': updatedAt?.millisecondsSinceEpoch,
      'categoryPath': category?.path,
    };
  }).toList();

  return Isolate.run(() {
    return rawProducts.map((product) {
      final price = product['price']! as double;
      return <String, Object?>{
        ...product,
        'priceWithTax': price * 1.2,
      };
    }).toList();
  });
}
```

#### Avoid sending snapshots or raw `doc.data()` across isolates

- `DocumentSnapshot`, `QueryDocumentSnapshot`, and `QuerySnapshot` hold references to `FirebaseFirestore` and `PlatformInterface` delegates, which are bound to the isolate that created them.
- `doc.data()` is not guaranteed to contain only plain Dart primitives. It can contain Firestore-specific objects such as `DocumentReference` (which carries the same `FirebaseFirestore` and platform-delegate references as a snapshot) as well as value types like `GeoPoint`, `Timestamp`, `Blob`, and `VectorValue`.

Explicitly map document fields into plain Dart values (or your own immutable model) before crossing the isolate boundary (for example: `ref.path`, `point.latitude`/`point.longitude`, `timestamp.millisecondsSinceEpoch`, `blob.bytes`, or `vector.toArray()`). This avoids sending `DocumentReference` instances across isolates and keeps the isolate payload self-contained and serializable.

For realtime updates, attach `snapshots()` listeners on the root isolate, convert each event's documents into plain Dart values, and offload heavy processing to `Isolate.run()` (or a long-lived worker isolate if events arrive frequently).

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
