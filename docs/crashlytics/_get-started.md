{# This content gets published to the following location:                      #}
{#   https://firebase.google.com/docs/crashlytics/get-started?platform=flutter #}

This quickstart describes how to set up {{firebase_crashlytics}} in your app
with the {{crashlytics}} Flutter plugin so that you can get comprehensive crash
reports in the {{name_appmanager}}.

Setting up {{crashlytics}} involves using both a command-line tool and your IDE.
To finish setup, you'll need to force a test exception to be thrown to send your
first crash report to Firebase.


## Before you begin {: #before-you-begin}

1.  If you haven't already,
    [configure and initialize Firebase](/docs/flutter/setup) in your Flutter
    project.

1.  **Recommended**: To get features like crash-free users, breadcrumb logs,
    and velocity alerts, you need to enable {{firebase_analytics}} in your
    Firebase project.

    All Android and Apple platforms supported by {{crashlytics}} (except
    watchOS) can take advantage of these features from {{firebase_analytics}}.

    Make sure that {{firebase_analytics}} is enabled in your Firebase project:
    Go to <nobr><span class="material-icons">settings</span> > _Project settings_</nobr> > _Integrations_ tab,
    then follow the on-screen instructions for {{firebase_analytics}}.


## **Step 1**: Add {{crashlytics}} to your Flutter project {: #add-sdk}

1.  From the root of your Flutter project, run the following command to install
    the {{crashlytics}} Flutter plugin:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutter pub add firebase_crashlytics
    ```

1.  From the root directory of your Flutter project, run the following command:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutterfire configure
    ```

    Running this command ensures that your Flutter app's Firebase configuration
    is up-to-date and, for Android, adds the required {{crashlytics}} Gradle
    plugin to your app.

1.  Once complete, rebuild your Flutter project:

    ```sh {: .devsite-terminal .devsite-click-to-copy data-terminal-prefix="your-flutter-proj$ " }
    flutter run
    ```

## **Step 2**: Configure crash handlers {: #configure-crash-handlers}

You can automatically catch all errors that are thrown within the Flutter
framework by overriding `FlutterError.onError` with
`FirebaseCrashlytics.instance.recordFlutterFatalError`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MyApp());
}
```

To catch asynchronous errors that aren't handled by the Flutter framework, use
`PlatformDispatcher.instance.onError`:


```dart
Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    runApp(MyApp());

}
```

For examples of how to handle other types of errors, see
[Customize crash reports](/docs/crashlytics/customize-crash-reports?platform=flutter).


## **Step 3**: Force a test crash to finish setup {:#force-test-crash}

To finish setting up {{crashlytics}} and see initial data in the {{crashlytics}}
dashboard of the {{name_appmanager}}, you need to force a test exception to be
thrown.

<<_force-test-crash.md>>

  If you've refreshed the console and you're still not seeing the test crash
  after five minutes,
  [enable debug logging](test-implementation#enable-debug-logging)
  to see if your app is sending crash reports.

<br>
And that's it! {{crashlytics}} is now monitoring your app for crashes and, on
Android, non-fatal errors and ANRs. Visit the
[{{crashlytics}} dashboard](https://console.firebase.google.com/project/_/crashlytics){: .external}
to view and investigate all your reports and statistics.


## Next steps {:#next-steps}

* [Customize your crash report setup](/docs/crashlytics/customize-crash-reports)
  by adding opt-in reporting, logs, keys, and tracking of additional non-fatal
  errors.

* [Integrate with {{play_name}}](/docs/crashlytics/integrate-with-google-play)
  so that you can filter your Android app's crash reports by {{play_name}} track
  directly in the {{crashlytics}} dashboard. This allows you to better focus
  your dashboard on specific builds.

* [View stack traces and crash statistics alongside your
  code](https://developer.android.com/studio/preview/features#aqi){: .external}
  with the _App Quality Insights_ window in Android Studio (available starting
  with Electric Eel 2022.1.1).
