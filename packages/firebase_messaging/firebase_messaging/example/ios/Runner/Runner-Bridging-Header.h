#import "GeneratedPluginRegistrant.h"

// `<firebase_messaging/...>` is the CocoaPods header layout. Swift Package
// Manager does not reproduce it - the plugin's public headers are only
// reachable through its generated Clang module - so the iOS SPM job cannot
// build this file unless both spellings are tried. The plugin's own headers
// use the same `__has_include` dance for `firebase_core`.
#if __has_include(<firebase_messaging/FLTFirebaseMessagingPlugin.h>)
#import <firebase_messaging/FLTFirebaseMessagingPlugin.h>
#else
@import firebase_messaging;
#endif
