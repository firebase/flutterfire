# Firebase AI Logic Flutter
[![pub package](https://img.shields.io/pub/v/firebase_ai.svg)](https://pub.dev/packages/firebase_ai)

A Flutter plugin to use the [Firebase AI Logic](https://firebase.google.com/docs/ai-logic) SDK, 
providing access to the latest generative [AI models](https://firebase.google.com/docs/ai-logic/models)
like Gemini and Imagen.

To learn more about Firebase AI, please visit the [Firebase website](https://firebase.google.com/docs/ai-logic)

## Getting Started

To get started with Firebase AI Logic Flutter, please [see the documentation](https://firebase.google.com/docs/ai-logic/get-started?platform=flutter).

## Usage

To start use this plugin, please visit the [Text only prompt documentation](https://firebase.google.com/docs/ai-logic/generate-text?platform=flutter)

## App Check Integration

If your app uses [Firebase App Check](https://firebase.google.com/docs/app-check), you can pass
the `AppCheck` instance directly to `FirebaseAI` to protect your Gemini API calls from unauthorized clients.

Add `firebase_app_check` to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_app_check: latest_version
```

Then initialize `FirebaseAI` with App Check:

```dart
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final model = FirebaseAI.instanceFor(
  appCheck: FirebaseAppCheck.instance,
).generativeModel(model: 'gemini-2.0-flash');
```

For more details, see the [App Check documentation](https://firebase.google.com/docs/app-check).

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).