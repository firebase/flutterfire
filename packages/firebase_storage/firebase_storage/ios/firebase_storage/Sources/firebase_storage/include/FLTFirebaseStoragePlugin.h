// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <TargetConditionals.h>

#if TARGET_OS_OSX
// Forward declarations of Firebase Storage type
@class FIRStorageTaskSnapshot;
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
@import FirebaseStorage;
#endif

#import <Foundation/Foundation.h>
#if __has_include(<firebase_core/FLTFirebasePlugin.h>)
#import <firebase_core/FLTFirebasePlugin.h>
#else
#import <FLTFirebasePlugin.h>
#endif
#import "firebase_storage_messages.g.h"

@interface FLTFirebaseStoragePlugin
    : FLTFirebasePlugin <FlutterPlugin, FLTFirebasePlugin, FirebaseStorageHostApi>

+ (NSDictionary *)parseTaskSnapshot:(FIRStorageTaskSnapshot *)snapshot;
+ (NSDictionary *)NSDictionaryFromNSError:(NSError *)error;
- (void)cleanUpTask:(NSString *)channelName handle:(NSNumber *)handle;
@end
