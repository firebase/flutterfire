#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
@import Firebase;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
  FIRAppCheckDebugProviderFactory *providerFactory = [[FIRAppCheckDebugProviderFactory alloc] init];
  [FIRAppCheck setAppCheckProviderFactory:providerFactory];
#endif
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
