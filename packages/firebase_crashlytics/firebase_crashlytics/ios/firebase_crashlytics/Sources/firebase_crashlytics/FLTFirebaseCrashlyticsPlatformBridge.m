//
//  FLTFirebaseCrashlyticsPlatformBridge.m
//  firebase_crashlytics
//
//  Objective-C bridge implementation for accessing private Firebase Crashlytics APIs
//

#import "FLTFirebaseCrashlyticsPlatformBridge.h"
#import "include/Crashlytics_Platform.h"
#import "include/ExceptionModel_Platform.h"

@implementation FLTFirebaseCrashlyticsPlatformBridge

+ (void)setupPlatformInfo {
    // Use private APIs to set platform information
    [[FIRCrashlytics crashlytics] setDevelopmentPlatformName:@"Flutter"];
    [[FIRCrashlytics crashlytics] setDevelopmentPlatformVersion:@"-1"];
}

+ (void)recordOnDemandException:(FIRExceptionModel *)exception {
    // Use public API method - Swift record(onDemandException:) becomes record: in Objective-C
    [[FIRCrashlytics crashlytics] record:exception];
}

+ (void)configureExceptionModel:(FIRExceptionModel *)exception
                       isFatal:(BOOL)isFatal
                      onDemand:(BOOL)onDemand {
    // Use private properties to configure exception
    exception.isFatal = isFatal;
    exception.onDemand = onDemand;
}

@end
