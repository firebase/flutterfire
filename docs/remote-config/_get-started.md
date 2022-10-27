{# This content gets published to the following location:                        #}
{#   https://firebase.google.com/docs/remote-config/get-started?platform=flutter #}

You can use Firebase Remote Config to define parameters in your app and update
their values in the cloud, allowing you to modify the appearance and behavior of
your app without distributing an app update.
This guide walks you through the steps to get started and provides some
sample code.

## Step 1: Add Firebase and the Remote Config SDK to your app {: #add-firebase }

1.  [Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup) if you
    haven't already done so.

1.  For Remote Config, Google Analytics is required for the
    [conditional targeting of app instances](/docs/remote-config/parameters#conditions_rules_and_conditional_values)
    to user properties and audiences. Make sure that
    you <a href="https://support.google.com/firebase/answer/9289399#linkga"
           class="external">enable Google Analytics</a> in your project.

1.  From the root directory of your Flutter project, run the following
    command to install the Remote Config plugin:

    ```bash
    flutter pub add firebase_remote_config
    ```

    Also, as part of setting up Remote Config, you need to add the Firebase SDK
    for Google Analytics to your app:

    ```bash
    flutter pub add firebase_analytics
    ```

1.  Rebuild your project:

    ```bash
    flutter run
    ```

Note: Because the Remote Config SDK has a dependency on the Remote Config REST
API, make sure that you do **not** disable that API, which is enabled by default
in a typical project.

## Step 2: Get the Remote Config singleton object {: #get-remote-config }

Get a Remote Config object instance and set the
minimum fetch interval to allow for frequent refreshes:

```dart
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
));
```

The singleton object is used to store in-app default parameter values, fetch
updated parameter values from the backend, and control when fetched values are
made available to your app.

During development, it's recommended to set a relatively low minimum fetch
interval. See [Throttling](#throttling) for more information.

## Step 3: Set in-app default parameter values {: #default-parameter }

You can set in-app default parameter values in the Remote Config
object, so that your app behaves as intended before it connects to the
Remote Config backend, and so that default values are available if none are
set in the backend.

```dart
await remoteConfig.setDefaults(const {
    "example_param_1": 42,
    "example_param_2": 3.14159,
    "example_param_3": true,
    "example_param_4": "Hello, world!",
});
```

## Step 4: Get parameter values to use in your app {: #get-parameter }

Now you can get parameter values from the Remote Config object. If you set
values in the backend, fetch them, and then activate them,
those values are available to your app. Otherwise, you get the in-app
parameter values configured using `setDefaults()`.

To get these values, call the method listed below that maps to the data type
expected by your app, providing the parameter key as an argument:

* `getBool()`
* `getDouble()`
* `getInt()`
* `getString()`

## Step 5: Set parameter values in the Remote Config backend {: #set-parameter }

Using the Firebase console or the
[Remote Config backend APIs](/docs/remote-config/automate-rc),
you can create new server-side default values that override the in-app values
according to your desired conditional logic or user targeting. This section
describes the Firebase console steps to create these values.

1. In the [Firebase console](https://console.firebase.google.com/), open your project.
1. Select **Remote Config** from the menu to view the Remote Config
   dashboard.
1. Define parameters with the same names as the parameters that you defined in
   your app. For each parameter, you can set a default value (which will
   eventually override the corresponding in-app default value), and you can also
   set conditional values. To learn more, see [Remote Config Parameters and
   Conditions](/docs/remote-config/parameters).

## Step 6: Fetch and activate values {: #fetch-values }

1. To fetch parameter values from the Remote Config backend, call the
   `fetch()` method. Any values that you set in the backend are fetched
   and stored in the Remote Config object.

1. To make fetched parameter values available to your app, call the
   `activate()` method.

   For cases where you want to fetch and activate values in one call, you
   can use a `fetchAndActivate()` request to fetch values from the
   Remote Config backend and make them available to the app:

   ```dart
   await remoteConfig.fetchAndActivate();
   ```

Because these updated parameter values affect the behavior and appearance
of your app, you should activate the fetched values at a time that ensures a
smooth experience for your user, such as the next time that the user opens your
app. See [Remote Config loading strategies](/docs/remote-config/loading)
for more information and examples.

## Throttling {: #throttling }

If an app fetches too many times in a short time period, fetch calls will be
throttled and the value of `FirebaseRemoteConfig`'s `lastFetchStatus`
property will be `RemoteConfigFetchStatus.throttle`.

The default minimum fetch interval for Remote Config is 12 hours, which
means that configs won't be fetched from the backend more than once in a 12 hour
window, regardless of how many fetch calls are actually made.

During app development, you might want to fetch and activate configs very frequently
(many times per hour) to let you rapidly iterate as you develop and test your
app. To accommodate rapid iteration on a project with up to 10 developers, you
can temporarily set a low minimum fetch interval with `setConfigSettings()`.

```dart
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(minutes: 5),
));
```

Caution: Keep in mind that this setting should be used for development only, not for an
app running in production. If you're just testing your app with a small
10-person development team, you are unlikely to hit the hourly service-side
quota limits. But if you pushed your app out to thousands of test users with a
very low minimum fetch interval, your app would probably hit this quota.
