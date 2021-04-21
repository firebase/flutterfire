# firebase_crashlytics_platform_interface

A common platform interface for the [`firebase_crashlytics`][1] plugin.

This interface allows platform-specific implementations of the `firebase_crashlytics`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

## Usage

To implement a new platform-specific implementation of `firebase_crashlytics`, extend
[`FirebaseCrashlyticsPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`FirebaseCrashlyticsPlatform` by calling
`FirebaseCrashlyticsPlatform.instance = MyCrashlytics()`.

## Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../firebase_crashlytics
[2]: lib/firebase_crashlytics_platform_interface.dart
