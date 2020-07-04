# firebase_crashlytics plugin

A Flutter plugin to use the [Firebase Crashlytics Service](https://firebase.google.com/docs/crashlytics/).

[![pub package](https://img.shields.io/pub/v/firebase_crashlytics.svg)](https://pub.dartlang.org/packages/firebase_crashlytics)

For Flutter plugins for other Firebase products, see [README.md](https://github.com/FirebaseExtended/flutterfire/blob/master/README.md).

## Usage

### Import the firebase_crashlytics plugin

To use the `firebase_crashlytics` plugin, follow the [plugin installation instructions](https://pub.dartlang.org/packages/firebase_crashlytics#pub-pkg-tab-installing).

The following instructions are from [the official installation page](https://firebase.google.com/docs/crashlytics/get-started-new-sdk).

### Android integration

Enable the Google services by configuring the Gradle scripts as such:

1. Check that you have Google's Maven repository in your **project-level** `build.gradle` file (`[project]/android/build.gradle`).

```gradle
buildscript {
  repositories {
    // Add this
    google()

    // ... you may have other repositories
  }
}
allprojects {
  repositories {
    // and this
    google()

    // ...
  }
}
```

2. Add the following classpaths to your **project-level** `build.gradle` file (`[project]/android/build.gradle`).

```gradle
buildscript {
  dependencies {
    // Check that you have the Google Services Gradle plugin v4.3.2 or later (if not, add it).
    classpath 'com.google.gms:google-services:4.3.3'
    
    // Add the Crashlytics Gradle plugin.
    classpath 'com.google.firebase:firebase-crashlytics-gradle:2.0.0'

    // ... you may have other classpaths
  }
}
```

3. Apply the following plugins in your **app-level** `build.gradle` file (`[project]/android/app/build.gradle`).

```gradle
// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

4. Add the SDK dependencies in your **app-level** `build.gradle` file (`[project]/android/app/build.gradle`).

```gradle
dependencies {
  // Optional but recommended: Add the Firebase SDK for Google Analytics.
  implementation 'com.google.firebase:firebase-analytics:17.4.0'

  // Add the Firebase SDK for Crashlytics.
  implementation 'com.google.firebase:firebase-crashlytics:17.0.0'
}
```

*Note:* If this section is not completed, you will get an error like this:

```console
java.lang.IllegalStateException:
Default FirebaseApp is not initialized in this process [package name].
Make sure to call FirebaseApp.initializeApp(Context) first.
```

*Note:* When you are debugging on Android, use a device or AVD with Google Play services.
Otherwise, you will not be able to use Firebase Crashlytics.

### iOS Integration

Add the Crashlytics run scripts:

1. From Xcode select `Runner` from the project navigation.
1. Select the `Build Phases` tab.
1. Click `+ Add a new build phase`, and select `New Run Script Phase`.
1. Add `${PODS_ROOT}/FirebaseCrashlytics/run` to the `Type a script...` text box.
1. If you are using Xcode 10, add the location of `Info.plist`, built by your app, to the `Build Phase's Input Files` field.  
   E.g.: `$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)`

### Use the plugin

Add the following imports to your Dart code:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
```

Setup `Crashlytics`:

```dart
void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  
  runApp(MyApp());
}
```

Overriding `FlutterError.onError` with `Crashlytics.instance.recordFlutterError`  will automatically catch all errors that are thrown from within the Flutter framework.

If you want to catch errors that occur in [`runZonedGuarded`](https://api.dart.dev/stable/dart-async/runZonedGuarded.html), you can supply `Crashlytics.instance.recordError` to the `onError` positioned parameter:

```dart
runZonedGuarded<Future<void>>(
  () async {
    // ...
  },
  Crashlytics.instance.recordError,
);
  }, onError: Crashlytics.instance.recordError);
```

Finally, to catch errors that happen outside Flutter context, install an error
listener on the current Isolate:

```dart
Isolate.current.addErrorListener(RawReceivePort((pair) async {
  final List<dynamic> errorAndStacktrace = pair;
  await Crashlytics.instance.recordError(
    errorAndStacktrace.first,
    errorAndStacktrace.last,
  );
}).sendPort);
```

## Result

If an error is caught, you should see the following messages in your logs:

```console
flutter: Flutter error caught by Crashlytics plugin:
// OR if you use recordError for runZonedGuarded:
flutter: Error caught by Crashlytics plugin <recordError>:
// Exception, context, information, and stack trace in debug mode
// OR if not in debug mode:
flutter: Error reported to Crashlytics.
```

*Note:* It may take awhile (up to 24 hours) before you will be able to see the logs appear in your Firebase console.

## Example

See the [example application](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_crashlytics/example) source
for a complete sample app using `firebase_crashlytics`.

## Issues and feedback

Please file Flutterfire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md),
and send a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
