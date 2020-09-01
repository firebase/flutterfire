# Firebase Cloud Storage for Flutter

[![pub package](https://img.shields.io/pub/v/firebase_storage.svg)](https://pub.dev/packages/firebase_storage)

A Flutter plugin to use the [Firebase Cloud Storage API](https://firebase.google.com/products/storage/).

To learn more about Firebase, please visit the [Firebase website](https://firebase.google.com)

## Getting Started

> If you are migrating your existing project to these new plugins, please start with the [migration guide](https://firebase.flutter.dev/docs/migration)

To get started with Cloud Storage for FlutterFire, please [see the documentation](https://firebase.flutter.dev/docs/storage/overview)
available at [https://firebase.flutter.dev](https://firebase.flutter.dev/docs/overview)

## Usage

To use any of the Firebase services, FlutterFire needs to be initialized.  To initialize FlutterFire,
call the `initializeApp` method on the `Firebase` class:

```dart
await Firebase.initializeApp();
```

### Basic Example

To upload a file to Firebase Storage, you need to first create a reference for the file, and then call either the
`putFile` or `putBlob` method that takes the passed data and uploads them to Firebase Storage:

```dart
Future<void> uploadFile() {
  // Create bucket storage reference to not yet existing file
  Reference ref = FirebaseStorage.instance.ref('/file-upload-test.txt');

  // Upload file
  UploadTask task = ref.putFile(file);
}
```

The `UploadTask` has a listener which may trigger events when transferring files.  When an event
occurs, a `TaskSnapshot` object gets passed back.  These events can be used to provide a way of monitoring
transfers:

```dart
// Listen for task events
task.snapshotEvents.listen((TaskSnapshot snapshot) {
  // Get task state such as running, progress and pause
  print('Snapshot state: ${snapshot.state}');
  // Calculate the task progress
  print('Progress: ${(snapshot.totalBytes/snapshot.bytesTransferred) * 100} %');
});

task.onComplete.then((TaskSnapshot snapshot){
  // Handle successful uploads on complete
  print('Upload Complete');
});
```

For more information on how to use this plugin,
please visit the [Storage Usage documentation](https://firebase.flutter.dev/docs/storage/overview)


## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
