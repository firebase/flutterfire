# firebase_core_web

The web implementation of [`firebase_core`][1].

## Usage

### Import the package

To use this plugin in your Flutter app on the web, simply add it as a
dependency in your `pubspec.yaml` alongside the base `firebase_core`
plugin.

_(This is only temporary: in the future we hope to make this package
an "endorsed" implementation of `firebase_core`, so it will automatically
be included in your app when you run your Flutter app on the web.)_

Add this to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  firebase_core: ^0.4.1
  firebase_core_web: ^0.1.0
  ...
```

### Using the plugin

Once you have added the `firebase_core_web` dependency to your pubspec,
you can use `package:firebase_core` as normal.

[1]: ../firebase_core/firebase_core
