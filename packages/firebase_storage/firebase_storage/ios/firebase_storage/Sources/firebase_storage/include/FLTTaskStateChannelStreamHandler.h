// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <TargetConditionals.h>

#if TARGET_OS_OSX
// Forward declarations of Firebase Storage type
@class FIRStorageObservableTask;
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
@import FirebaseStorage;
#endif

#import <Foundation/Foundation.h>
#import "FLTFirebaseStoragePlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLTTaskStateChannelStreamHandler : NSObject <FlutterStreamHandler>
- (instancetype)initWithTask:(FIRStorageObservableTask *)task
               storagePlugin:(FLTFirebaseStoragePlugin *)storagePlugin
                 channelName:(NSString *)channelName
                      handle:(NSNumber *)handle;

@end

NS_ASSUME_NONNULL_END
