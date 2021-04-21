# Firebase Machine Learning Custom

[![pub package](https://img.shields.io/pub/v/firebase_ml_custom.svg)](https://pub.dev/packages/firebase_ml_custom)

A Flutter plugin to use the [Firebase ML Custom Models API](https://firebase.google.com/docs/ml/use-custom-models).

For Flutter plugins for other Firebase products, see [README.md](https://github.com/FirebaseExtended/flutterfire/blob/master/README.md).

## Usage

To use this plugin, add `firebase_ml_custom` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You must also configure Firebase for each platform project: Android and iOS (see the example folder or https://codelabs.developers.google.com/codelabs/flutter-firebase/#4 for step by step details).

### Android

In order to use methods referencing those of [Firebase Model Manager](https://firebase.google.com/docs/reference/android/com/google/firebase/ml/common/modeldownload/FirebaseModelManager) minimum SDK version required is 24.
Otherwise minimum SDK version is 21.
This can be specified in your app-level `build.gradle` file.

### iOS

A minimum deployment target of 9.0 is required. You can add the line `platform :ios, '9.0'` in your iOS project `Podfile`.

You may also need to update your app's deployment target to 9.0 using Xcode. Otherwise, you may see
compilation errors.

## Using Firebase Model Manager

### 1. Create a `FirebaseCustomRemoteModel`.

Create a `FirebaseCustomRemoteModel` object. 
You should already have a model in your Firebase console available for download. Use the name that you gave your model in the Firebase console.

```dart
FirebaseCustomRemoteModel remoteModel = FirebaseCustomRemoteModel('myModelName');
```

### 2. Create a `FirebaseModelDownloadConditions`.

Create a `FirebaseModelDownloadConditions` object.
Specify optional platform-specific conditions for the model download.

```dart
FirebaseModelDownloadConditions conditions =
    FirebaseModelDownloadConditions(
        androidRequireWifi: true,
        androidRequireDeviceIdle: true,
        androidRequiredCharging: true,
        iosAllowCellularAccess: false,
        iosAllowBackgroundDownloading: true);
```
All of these parameters except `iosAllowCellularAccess` default to `false` if not specified. `iosAllowCellularAccess` defaults to `true`.
Each platform looks only at its platform-specific parameters and ignores the rest.

### 3. Create an instance of `FirebaseModelManager`.

Create a `FirebaseModelManager` object corresponding to the default `FirebaseApp` instance.
```dart
FirebaseModelManager modelManager = FirebaseModelManager.instance;
```

### 4. Call `download()` with `FirebaseCustomRemoteModel` and `FirebaseModelDownloadConditions`.

Initiate the download of a remote model if the download hasn't begun.
If the model's download is already in progress, the current download task will continue executing.
If the model is already downloaded to the device, and there is no update, the call will immediately succeed.
If the model is already downloaded to the device, and there is update, a download for the updated version will be attempted.
```dart
await modelManager.download(remoteModel, conditions);
```

### 5. Call `isModelDownloaded()` with `FirebaseCustomRemoteModel`.

Return whether the given remote model is currently downloaded.
```dart
if (await modelManager.isModelDownloaded(model) == true) ) {
    // do something with this model
} else {
    // fall back on a locally-bundled model or do something else
}
```

You can also check if download was successfully completed by surrounding download method with `try` and `catch`.

### 5. Call `getLatestModelFile()` with `FirebaseCustomRemoteModel`.

Return the `File` containing the latest model for the remote model name. This will fail if the model is not yet downloaded on the device or valid custom remote model is not provided.

```dart
File modelFile = await modelManager.getLatestModelFile(model);
```

You can feed this file directly into an interpreter or preprocess it, depending on the interpreter of your choice.

Possible Flutter TF Lite interpreters:
- [tflite](https://pub.dev/packages/tflite)
- [tflite_flutter](https://pub.dev/packages/tflite_flutter)

Google does not recommend usage of any specific interpreter and leaves it up to the user to decide.

## Getting Started

See the `example` directory for a complete sample app using Firebase Machine Learning Custom.

## Issues and feedback

Please file Flutterfire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md),
and send a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
