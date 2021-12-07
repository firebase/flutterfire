# firebase_ml_model_downloader_platform_interface

A common platform interface for the [`firebase_ml_model_downloader`][1] plugin.

This interface allows platform-specific implementations of the `firebase_ml_model_downloader`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `firebase_ml_model_downloader`, extend
[`FirebaseMlModelDownloaderPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`FirebaseMlModelDownloaderPlatform` by calling
`FirebaseMlModelDownloaderPlatform.instance = MyFirebaseMlModelDownloader()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../firebase_ml_model_downloader
[2]: lib/firebase_ml_model_downloader_platform_interface.dart
