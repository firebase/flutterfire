//
//  FLTFirebaseCrashlyticsPlatformBridge.h
//  firebase_crashlytics
//
//  Objective-C bridge for accessing private Firebase Crashlytics APIs
//

@import Foundation;
@import FirebaseCrashlytics;

NS_ASSUME_NONNULL_BEGIN

@interface FLTFirebaseCrashlyticsPlatformBridge : NSObject

/// Setup platform information using private APIs
+ (void)setupPlatformInfo;

/// Record an on-demand exception using private APIs
+ (void)recordOnDemandException:(FIRExceptionModel *)exception;

/// Configure an exception model with private properties
+ (void)configureExceptionModel:(FIRExceptionModel *)exception
                       isFatal:(BOOL)isFatal
                      onDemand:(BOOL)onDemand;

@end

NS_ASSUME_NONNULL_END
