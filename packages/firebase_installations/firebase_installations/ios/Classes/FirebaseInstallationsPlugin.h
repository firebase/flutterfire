#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <firebase_core/FLTFirebasePlugin.h>

@interface FirebaseInstallationsPlugin : FLTFirebasePlugin <FlutterPlugin, FLTFirebasePlugin>
@end
