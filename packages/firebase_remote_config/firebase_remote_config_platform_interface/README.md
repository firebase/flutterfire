# firebase_remote_config_platform_interface

A common platform interface for the [`firebase_remote_config`][1] plugin.

This interface allows platform-specific implementations of the `firebase_remote_config`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `firebase_remote_config`, extend
[`FirebaseRemoteConfigPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`FirebaseRemoteConfigPlatform` by calling
`FirebaseRemoteConfigPlatform.instance = MyRemoteConfig()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../firebase_remote_config
[2]: lib/firebase_remote_config_platform_interface.dart
