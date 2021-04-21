// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_core_platform_interface;

/// Throws a consistent cross-platform error message when usage of an app occurs but
/// no app has been created.
FirebaseException noAppExists(String appName) {
  return FirebaseException(
      plugin: 'core',
      code: 'no-app',
      message:
          "No Firebase App '$appName' has been created - call Firebase.initializeApp()");
}

/// Throws a consistent cross-platform error message when an app is being created
/// which already exists.
FirebaseException duplicateApp(String appName) {
  return FirebaseException(
      plugin: 'core',
      code: 'duplicate-app',
      message: 'A Firebase App named "$appName" already exists');
}

/// Throws a consistent cross-platform error message if the user attempts to
/// initialize the default app from FlutterFire.
FirebaseException noDefaultAppInitialization() {
  return FirebaseException(
    plugin: 'core',
    message: 'The $defaultFirebaseAppName app cannot be initialized here. '
        'To initialize the default app, follow the installation instructions '
        'for the specific platform you are developing with.',
  );
}

/// Throws a consistent platform specific error message if the user attempts to
/// initializes core without it being available on the underlying platform.
FirebaseException coreNotInitialized() {
  String message;

  if (kIsWeb) {
    message = '''
Firebase has not been correctly initialized. Have you added the Firebase import scripts to your index.html file? 
    
View the Web Installation documentation for more information: https://firebase.flutter.dev/docs/installation/web
    ''';
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    message = '''
Firebase has not been correctly initialized. Have you added the "google-services.json" file to the project? 
    
View the Android Installation documentation for more information: https://firebase.flutter.dev/docs/installation/android
''';
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    message = '''
Firebase has not been correctly initialized. Have you added the "GoogleService-Info.plist" file to the project? 
    
View the iOS Installation documentation for more information: https://firebase.flutter.dev/docs/installation/ios
''';
  } else {
    message = 'Firebase has not been initialized. '
        'Please check the documentation for your platform.';
  }

  return FirebaseException(
      plugin: 'core', code: 'not-initialized', message: message);
}

/// Throws a consistent cross-platform error message if the user attempts
/// to delete the default app.
FirebaseException noDefaultAppDelete() {
  return FirebaseException(
    plugin: 'core',
    message: 'The default Firebase app instance cannot be deleted.',
  );
}
