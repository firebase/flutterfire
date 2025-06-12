{# This content gets published to the following location:                                  #}
{#   https://firebase.google.com/docs/crashlytics/customize-crash-reports?platform=flutter #}

In the {{crashlytics}} dashboard, you can click into an issue and get a detailed
event report. You can customize those reports to help you better understand
what's happening in your app and the circumstances around events reported to
{{crashlytics}}.

* Report [uncaught exceptions](#report-uncaught-exceptions) and
  [caught exceptions](#report-caught-exceptions) to {{crashlytics}}.

* Instrument your app to log [custom keys](#add-keys),
  [custom log messages](#add-logs), and [user identifiers](#set-user-ids).

* Automatically get [breadcrumb logs](#get-breadcrumb-logs) if your app uses the
  Firebase SDK for {{firebase_analytics}}. These logs give you visibility into
  user actions leading up to a {{crashlytics}}-collected event in your app.

* Turn off automatic crash reporting and
  [enable opt-in reporting](#enable-reporting) for your users. Note that, by
  default, {{crashlytics}} automatically collects platform-native crash reports
  for all your app's users.

Note: For Flutter apps, fatal reports are sent to {{crashlytics}} in real-time
without the need for the user to restart the application. Non-fatal reports are
written to disk to be sent along with the next fatal report or when the app
restarts.

## Report uncaught exceptions {: #report-uncaught-exceptions}

You can automatically catch all "fatal" errors that are thrown within the Flutter
framework by overriding `FlutterError.onError` with
`FirebaseCrashlytics.instance.recordFlutterFatalError`. Alternatively,
to also catch "non-fatal" exceptions, override `FlutterError.onError` with `FirebaseCrashlytics.instance.recordFlutterError`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  bool weWantFatalErrorRecording = true;
  FlutterError.onError = (errorDetails) {
    if(weWantFatalErrorRecording){
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    } else {
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };

  runApp(MyApp());
}
```

### Asynchronous errors {: #asynchronous-errors}

Asynchronous errors are not caught by the Flutter framework:

```dart
ElevatedButton(
  onPressed: () async {
    throw Error();
  }
  ...
)
```

To catch such errors, you can use the `PlatformDispatcher.instance.onError` handler:

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

### Errors outside of Flutter {: #errors-outside-flutter}

To catch errors that happen outside of the Flutter context, install an error
listener on the current `Isolate`:

```dart
Isolate.current.addErrorListener(RawReceivePort((pair) async {
  final List<dynamic> errorAndStacktrace = pair;
  await FirebaseCrashlytics.instance.recordError(
    errorAndStacktrace.first,
    errorAndStacktrace.last,
    fatal: true,
  );
}).sendPort);
```

## Report caught exceptions {: #report-caught-exceptions}

In addition to automatically reporting your app’s crashes, {{crashlytics}} lets
you record non-fatal exceptions and sends them to you the next time a fatal
event is reported or when the app restarts.

Note: {{crashlytics}} only stores the most recent eight recorded non-fatal
exceptions. If your app throws more than eight, older exceptions are lost. This
count is reset each time a fatal exception is thrown, since this causes a report
to be sent to {{crashlytics}}.

Use the `recordError` method to record non-fatal exceptions in your app's catch
blocks. For example:

```dart
await FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'a non-fatal error'
);

// Or you can use:
await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
```

You may also want to log further information about the error which is possible
using the `information` property:

```dart
await FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'a non-fatal error',
  information: ['further diagnostic information about the error', 'version 2.0'],
);
```

Warning: If you want to include a unique value (for example, a user ID or a
timestamp) in your exception message, use a [custom key](#add-keys) instead of
adding the value directly in the exception message. Adding values directly can
result in several issues and may cause {{crashlytics}} to limit reporting errors
in your app.

These exceptions appear as non-fatal issues in the {{name_appmanager}}. The
issue summary contains all the state information you normally get from crashes,
along with breakdowns by version and hardware device.

{{crashlytics}} processes exceptions on a dedicated background thread to
minimize the performance impact to your app. To reduce your users’ network
traffic, {{crashlytics}} will rate-limit the number of reports sent off device,
if necessary.

## Add custom keys {: #add-keys}

Custom keys help you get the specific state of your app leading up to a crash.
You can associate arbitrary key/value pairs with your crash reports, then use
the custom keys to search and filter crash reports in the {{name_appmanager}}.

* In the [{{crashlytics}} dashboard](https://console.firebase.google.com/project/_/crashlytics){:.external},
  you can search for issues that match a custom key.

* When you're reviewing a specific issue in the console, you can view the
  associated custom keys for each event (_Keys_ subtab) and even filter the
  events by custom keys (_Filter_ menu at the top of the page).

Note: {{crashlytics}} supports a maximum of 64 key/value pairs. After you reach
this threshold, additional values are not saved. Each key/value pair can be up
to 1 kB in size.

Use the `setCustomKey` instance method to set key/value pairs. Here are some
examples:

```dart
// Set a key to a string.
FirebaseCrashlytics.instance.setCustomKey('str_key', 'hello');

// Set a key to a boolean.
FirebaseCrashlytics.instance.setCustomKey("bool_key", true);

// Set a key to an int.
FirebaseCrashlytics.instance.setCustomKey("int_key", 1);

// Set a key to a long.
FirebaseCrashlytics.instance.setCustomKey("int_key", 1L);

// Set a key to a float.
FirebaseCrashlytics.instance.setCustomKey("float_key", 1.0f);

// Set a key to a double.
FirebaseCrashlytics.instance.setCustomKey("double_key", 1.0);
```

## Add custom log messages {: #add-logs}

To give yourself more context for the events leading up to a crash, you can add
custom {{crashlytics}} logs to your app. {{crashlytics}} associates the logs
with your crash data and displays them in the
[{{name_appmanager}}](https://console.firebase.google.com/project/_/crashlytics){: .external},
under the {{crashlytics}} **Logs** tab.

Note: To avoid slowing down your app, {{crashlytics}} limits logs to 64kB
and deletes older log entries when a session's logs go over that limit.

Use `log` to help pinpoint issues. For example:

```dart
FirebaseCrashlytics.instance.log("Higgs-Boson detected! Bailing out");
```

## Set user identifiers {: #set-user-ids}

To diagnose an issue, it’s often helpful to know which of your users experienced
a given crash. {{crashlytics}} includes a way to anonymously identify users in
your crash reports.

To add user IDs to your reports, assign each user a unique identifier in the
form of an ID number, token, or hashed value:

```dart
FirebaseCrashlytics.instance.setUserIdentifier("12345");
```

If you ever need to clear a user identifier after you set it, reset the value to
a blank string. Clearing a user identifier does not remove existing
{{crashlytics}} records. If you need to delete records associated with a user
ID, [contact Firebase support](/support/troubleshooter/contact/).

## Get breadcrumb logs {: #get-breadcrumb-logs}

Breadcrumb logs give you a better understanding of the interactions that a user
had with your app leading up to a crash, non-fatal, or ANR event. These logs can
be helpful when trying to reproduce and debug an issue.

Breadcrumb logs are powered by Google Analytics, so to get breadcrumb logs, you
need to
[enable Google Analytics](https://support.google.com/firebase/answer/9289399#linkga){: .external}
for your Firebase project and
[add the Firebase SDK for {{firebase_analytics}}](/docs/analytics/get-started#add-sdk)
to your app. Once these requirements are met, breadcrumb logs are automatically
included with an event's data within the **Logs** tab when you view the details
of an issue.

The {{analytics}} SDK
[automatically logs the `screen_view` event](https://support.google.com/analytics/answer/9234069#screen_view){: .external}
which enables the breadcrumb logs to show a list of screens viewed before the
crash, non-fatal, or ANR event. A `screen_view` breadcrumb log contains a
`firebase_screen_class` parameter.

Breadcrumb logs are also populated with any
[custom events](/docs/analytics/events) that you manually log within the user's
session, including the event's parameter data. This data can help show a series
of user actions leading up to a crash, non-fatal, or ANR event.

Note that you can
[control the collection and use of {{firebase_analytics}} data](/docs/analytics/configure-data-collection),
which includes the data that populates breadcrumb logs.

## Enable opt-in reporting {: #enable-reporting}

<<../_includes/customize-crash-reports/_enable-opt-in_impact-awareness-note.md>>

By default, {{crashlytics}} automatically collects crash reports for all your
app's users. To give users more control over the data they send, you can enable
opt-in reporting by disabling automatic reporting and only sending data to
{{crashlytics}} when you choose to in your code.

1.  Turn off automatic collection natively:

    **Apple platforms**

    Add a new key to your `Info.plist` file:

    * Key: `FirebaseCrashlyticsCollectionEnabled`
    * Value: `false`

    **Android**

    In the `application` block of your `AndroidManifest.xml` file, add
    a `meta-data` tag to turn off automatic collection:

    ```xml
    <meta-data
        android:name="firebase_crashlytics_collection_enabled"
        android:value="false" />
    ```

1.  Enable collection for select users by calling the {{crashlytics}} data
    collection override at runtime. The override value persists across all
    subsequent launches of your app so {{crashlytics}} can automatically collect
    reports for that user.

    ```dart
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    ```

    If the user later opts-out of data collection, you can pass `false` as the
    override value, which will apply the next time the user launches the app and
    will persist across all subsequent launches for that user.

Note: When data collection is disabled for a user, {{crashlytics}} will
store crash information locally on the device. If data collection is
subsequently enabled, any crash information stored on the device will be
sent to {{crashlytics}} for processing.