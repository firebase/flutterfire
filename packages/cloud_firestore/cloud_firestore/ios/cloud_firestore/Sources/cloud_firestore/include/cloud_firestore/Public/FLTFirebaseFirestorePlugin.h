// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <Foundation/Foundation.h>
#if __has_include(<firebase_core/FLTFirebasePlugin.h>)
#import <firebase_core/FLTFirebasePlugin.h>
#else
#import <FLTFirebasePlugin.h>
#endif
#import "FirestoreMessages.g.h"

@interface FLTFirebaseFirestorePlugin
    : FLTFirebasePlugin <FlutterPlugin, FLTFirebasePlugin, FirebaseFirestoreHostApi>
+ (NSMutableDictionary<NSNumber *, NSString *> *)serverTimestampMap;
@end
