[<img src="https://raw.githubusercontent.com/firebase/flutterfire/main/.github/images/flutter_favorite.png" width="200" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

# Cloud Firestore Plugin for Flutter

A Flutter plugin to use the [Cloud Firestore API](https://firebase.google.com/docs/firestore/).

To learn more about Firebase Cloud Firestore, please visit the [Firebase website](https://firebase.google.com/products/firestore)

[![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore)

## Getting Started

To get started with Cloud Firestore for Flutter, please [see the documentation](https://firebase.google.com/docs/firestore/quickstart).

## Usage

To use this plugin, please visit the [Firestore Usage documentation](https://firebase.google.com/docs/firestore/manage-data/add-data)

## Using Cloud Firestore with Isolates

Cloud Firestore (like most FlutterFire plugins) talks to native code through
platform channels. Those channels are only available on the **main isolate**.

That means you **cannot** call Firestore APIs inside `compute()`,
`Isolate.run()`, or a background isolate spawned with `Isolate.spawn()`:

```dart
// ❌ This will fail — Firestore cannot use platform channels off the main isolate.
await compute((_) async {
  final snapshot = await FirebaseFirestore.instance.collection('users').get();
  return snapshot.docs.length;
}, null);
```

### Recommended pattern

1. **Fetch on the main isolate** (where Firebase is initialized).
2. Convert results to **plain Dart data** (`Map` / `List` / your own model).
3. **Process** that data in a background isolate if the work is CPU-heavy.

```dart
// ✅ Fetch on the main isolate
final snapshot =
    await FirebaseFirestore.instance.collection('products').get();

// Pass only sendable data into the isolate
final raw = snapshot.docs.map((doc) => doc.data()).toList();

final processed = await Isolate.run(() {
  // Heavy CPU work only — no Firebase / plugin calls here
  return raw.map((data) {
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    return price * 1.2; // example transform
  }).toList();
});
```

### Why DocumentSnapshot / QuerySnapshot are not enough

`DocumentSnapshot`, `QueryDocumentSnapshot`, and similar types are **not** safe
to send across isolates. Always extract `data()` (or map to your own immutable
model) before calling `Isolate.run` / `compute`.

### Streams and listeners

Realtime listeners (`snapshots()`) must also be attached on the main isolate.
If you need background work per event, map each event to plain data first, then
offload processing.

### Related issues

- [#3124](https://github.com/firebase/flutterfire/issues/3124)
- [#4129](https://github.com/firebase/flutterfire/issues/4129)
- [#4846](https://github.com/firebase/flutterfire/issues/4846)

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
