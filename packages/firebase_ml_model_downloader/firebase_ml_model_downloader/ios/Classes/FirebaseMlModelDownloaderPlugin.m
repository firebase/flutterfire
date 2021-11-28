#import "FirebaseMlModelDownloaderPlugin.h"
#if __has_include(<firebase_ml_model_downloader/firebase_ml_model_downloader-Swift.h>)
#import <firebase_ml_model_downloader/firebase_ml_model_downloader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "firebase_ml_model_downloader-Swift.h"
#endif

@implementation FirebaseMlModelDownloaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFirebaseMlModelDownloaderPlugin registerWithRegistrar:registrar];
}
@end
