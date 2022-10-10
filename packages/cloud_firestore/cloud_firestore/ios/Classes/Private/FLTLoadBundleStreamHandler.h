//
//  FLTLoadBundleStreamHandler.h
//  Pods
//
//  Created by Russell Wheatley on 05/05/2021.
//
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <Firebase/Firebase.h>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTLoadBundleStreamHandler : NSObject <FlutterStreamHandler>

@end

NS_ASSUME_NONNULL_END
