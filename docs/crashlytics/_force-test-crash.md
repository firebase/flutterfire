{# This content gets published to the following location:                              #}
{#   https://firebase.google.com/docs/crashlytics/test-implementation?platform=flutter #}

1.  Add code to your app that you can use to force a test exception to be
    thrown.

    If you’ve added an error handler that calls
    `FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)` to the
    top-level `Zone`, you can use the following code to add a button to your app
    that, when pressed, throws a test exception:

    ```dart
    TextButton(
        onPressed: () => throw Exception(),
        child: const Text("Throw Test Exception"),
    ),
    ```

1.  Build and run your app.

1.  Force the test exception to be thrown in order to send your app's first
    report:

    1.  Open your app from your test device or emulator.

    1.  In your app, press the test exception button that you added using the
        code above.

1.  Go to the
    [{{crashlytics}} dashboard](https://console.firebase.google.com/project/_/crashlytics){: .external}
    of the {{name_appmanager}} to see your test crash.
