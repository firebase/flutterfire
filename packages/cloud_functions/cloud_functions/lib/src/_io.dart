import 'dart:io' show Platform;

/// Checks whether current platform is Android or not.
/// Backed by `Platform.isAndroid`
bool get isPlatformAndroid => Platform.isAndroid;
