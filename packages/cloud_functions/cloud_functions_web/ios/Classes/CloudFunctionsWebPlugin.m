#import "CloudFunctionsWebPlugin.h"
#if __has_include(<cloud_functions_web/cloud_functions_web-Swift.h>)
#import <cloud_functions_web/cloud_functions_web-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cloud_functions_web-Swift.h"
#endif

@implementation CloudFunctionsWebPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCloudFunctionsWebPlugin registerWithRegistrar:registrar];
}
@end
