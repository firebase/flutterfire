//
//  FLTDocumentSnapshotStreamHandler.h
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

NS_ASSUME_NONNULL_BEGIN

@interface FLTDocumentSnapshotStreamHandler : NSObject<FlutterStreamHandler>

@end

NS_ASSUME_NONNULL_END
