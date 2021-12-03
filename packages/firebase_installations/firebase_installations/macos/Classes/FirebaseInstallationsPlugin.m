#import "FirebaseInstallationsPlugin.h"
#if __has_include(<firebase_installations/firebase_installations-Swift.h>)
#import <firebase_installations/firebase_installations-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "firebase_installations-Swift.h"
#endif

@implementation FirebaseInstallationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFirebaseInstallationsPlugin registerWithRegistrar:registrar];
}

- (void)didReinitializeFirebaseCore:(void (^_Nonnull)(void))completion {
  completion();
}

- (NSString* _Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString* _Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString* _Nonnull)flutterChannelName {
  return @"plugins.flutter.io/firebase_installations";
}

- (NSDictionary* _Nonnull)pluginConstantsForFIRApp:(FIRApp* _Nonnull)firebaseApp {
  return @{};
}

@end
