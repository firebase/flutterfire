//
//  FLTQuerySnapshotStreamHandler.h
//  cloud_firestore
//
//  Created by Sebastian Roth on 24/11/2020.
//

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <Foundation/Foundation.h>

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTQuerySnapshotStreamHandler : NSObject<FlutterStreamHandler>

@end

NS_ASSUME_NONNULL_END
