#import "AppDelegate.h"
#import "AuthCallbackURLTestChannel.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Only used by integration_test/e2e_test.dart.
  [AuthCallbackURLTestChannel
      registerWithRegistrar:[self registrarForPlugin:@"AuthCallbackURLTestChannel"]];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
