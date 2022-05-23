{# This content gets published to the following location:                   #}
{#   https://firebase.google.com/docs/perf-mon/disable-sdk?platform=flutter #}

During app development and testing, you might find it useful to disable
Performance Monitoring.

For example, by
[disabling Performance Monitoring during your app build process](#disable-during-build),
you can:

* Disable certain functionalities of Performance Monitoring in your debug
  builds, but re-enable the functionalities for your release build.

* Disable Performance Monitoring when building your app, but allow your app to
  re-enable it at runtime.

* Disable Performance Monitoring when building your app, and do not allow your
  app to re-enable it at runtime.

You can also build your app with Performance Monitoring _enabled_, but
[use Firebase Remote Config](#disable-with-remote-config) to give you
flexibility to disable (and re-enable) Performance Monitoring in your production
app. With this option, you can even configure your app to let users opt-in or
opt-out of using Performance Monitoring.

## Disable Performance Monitoring during your app build process {: #disable-during-build}

One situation where disabling Performance Monitoring during your app build
process could be useful is to avoid reporting performance data from a
pre-release version of your app during app development and testing.

To do so, see the platform-specific [iOS+](?platform=ios) and
[Android](?platform=android) docs.


## Disable your app at runtime using Remote Config {: #disable-with-remote-config}

[Firebase Remote Config](/docs/remote-config/get-started?platform=flutter) lets
you make changes to the behavior and appearance of your app, so it provides an
ideal way to let you disable Performance Monitoring in deployed instances of
your app.

For example, suppose you want to use a parameter called `perf_disable` to
remotely control Performance Monitoring. Add the following to your startup code
to enable or disable Performance Monitoring:

```dart
// Activate previously-fetched values, falling back on the defaults if
// nothing is available yet.
await FirebaseRemoteConfig.instance
    .setDefaults(YOUR_REMOTE_CONFIG_DEFAULTS);
await FirebaseRemoteConfig.instance.activate();

// Enable or disable Performance Monitoring based on the value of
// "perf_disable".
final perfMonDisabled =
    FirebaseRemoteConfig.instance.getBool("perf_disable");
FirebasePerformance.instance
    .setPerformanceCollectionEnabled(!perfMonDisabled);

// Fetch values for next time. (Don't await the result!)
FirebaseRemoteConfig.instance.fetch();
```

Note: This snippet requires an app restart to activate configuration changes.
See [Loading strategies](/docs/remote-config/loading) for alternatives.


