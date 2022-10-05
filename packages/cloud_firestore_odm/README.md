# Cloud Firestore ODM Package for Flutter

[![pub package](https://img.shields.io/pub/v/cloud_firestore_odm.svg)](https://pub.dev/packages/cloud_firestore_odm)

The Cloud Firestore ODM package enables developers to build fully type-safe applications for Flutter using the FlutterFire Cloud Firestore plugin.

> The Cloud Firestore ODM is currently in **alpha**. Expect breaking changes, API changes and more. The documentation is still a work in progress. See the [discussion](https://github.com/firebase/flutterfire/discussions/7475) for more details.

## What is an ODM?

The Object Document Mapper or ODM is an interface that treats a document as a tree structure wherein each node is an object representing a part of the document.   
ODM methods allow programmatic access to the tree making it possible to change the structure, style or content of a document. 

##  What does it do?

The Cloud Firestore ODM package enables developers to build fully type-safe applications for Flutter using the FlutterFire Cloud Firestore plugin.

The ODM allows data schemas to be defined which represent the data structure of your Cloud Firestore database. By defining schemas the ODM provides the following benefits:

- ↔️ Bi-directional data validation.
- 🔒 Type-safe data querying, supporting all Firestore query operations.
- 🔄 Flutter Widgets for simple data binding with your data.
- 🎯 Data selectors to help avoid unnecessary Widget rebuilds.
- 💻 Full API code completion.

## Installation

### 1. Use a recent Dart version

The ODM relies on a recent Dart feature: generic annotations.  
As such, to use the ODM you will need to upgrade your Dart SDK to enable this feature.

That is done by adding the following to your `pubspec.yaml`:

```yaml
environment:
  sdk: ">=2.16.0 <3.0.0"
```

### 2. FlutterFire Initialization

Before getting started, [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup).

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### 3. Install `cloud_firestore` plugin

The ODM depends on the `cloud_firestore` plugin, so first ensure you have it
[installed on your project](https://firebase.google.com/docs/firestore/quickstart#dart).

### 4. Install dependency

To install the ODM, you'll need to install both the [`cloud_firestore_odm`](https://pub.dev/packages/cloud_firestore_odm) and [`json_annotation`](https://pub.dev/packages/json_annotation) packages
from pub:

```bash
flutter pub add cloud_firestore_odm
flutter pub add json_annotation
```

Next, install the `build_runner`, `cloud_firestore_odm_generator` & `json_serializable` packages as development dependencies:

```bash
flutter pub add --dev build_runner
flutter pub add --dev cloud_firestore_odm_generator
flutter pub add --dev json_serializable
```

## Next Steps

Once installed, read the documentation on [defining models](./doc/defining-models.md).

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
