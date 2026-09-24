# Firebase AI Logic Flutter
[![pub package](https://img.shields.io/pub/v/firebase_ai.svg)](https://pub.dev/packages/firebase_ai)

A Flutter plugin to use the [Firebase AI Logic](https://firebase.google.com/docs/ai-logic) SDK, 
providing access to the latest generative [AI models](https://firebase.google.com/docs/ai-logic/models)
like Gemini and Imagen.

To learn more about Firebase AI, please visit the [Firebase website](https://firebase.google.com/docs/ai-logic)

## Supported platforms

Android, iOS, macOS, web, and Windows.

### Windows

`firebase_ai` runs on Windows desktop. Generation requests are plain Dart HTTP.
Windows does not send app-identity headers (`X-Android-Package`,
`X-Android-Cert`, or `x-ios-bundle-identifier`), so an API key restricted to an
Android app or an Apple bundle ID will not authorize a Windows client. Use a
key that allows this client, the same way you would for web.

Windows App Check only supports the debug provider, and that provider is for
local development. There is no production attestation provider. If App Check is
enforced for Firebase AI Logic, production Windows clients cannot obtain a
valid token.

## Getting Started

To get started with Firebase AI Logic Flutter, please [see the documentation](https://firebase.google.com/docs/ai-logic/get-started?platform=flutter).

## Usage

To start use this plugin, please visit the [Text only prompt documentation](https://firebase.google.com/docs/ai-logic/generate-text?platform=flutter)

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
