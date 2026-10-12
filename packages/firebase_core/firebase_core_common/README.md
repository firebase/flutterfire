# firebase_core_common

Pure Dart shared types and platform interfaces used by
[`firebase_core`](https://pub.dev/packages/firebase_core) and its platform
implementations.

This package contains no Flutter dependency and never imports `package:flutter/*`
(neither directly nor transitively). It exists so that platform implementations
such as [`firebase_core_web`](https://pub.dev/packages/firebase_core_web) can be
used outside of Flutter, for example in pure Dart web applications.

It is not intended to be used directly by end users. The Flutter facing API is
exposed by `firebase_core`, and `firebase_core_platform_interface` re-exports
this package for backwards compatibility.
