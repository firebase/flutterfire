// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTQuerySnapshotStreamHandler : NSObject <FlutterStreamHandler>
@property(nonatomic, strong) FIRFirestore *firestore;
@property(nonatomic, strong) FIRQuery *query;
@property(nonatomic, assign) BOOL includeMetadataChanges;
@property(nonatomic, assign) FIRListenSource source;
@property(nonatomic, assign) FIRServerTimestampBehavior serverTimestampBehavior;

- (instancetype)initWithFirestore:(FIRFirestore *)firestore
                            query:(FIRQuery *)query
           includeMetadataChanges:(BOOL)includeMetadataChanges
          serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior
                           source:(FIRListenSource)source;

@end

NS_ASSUME_NONNULL_END
