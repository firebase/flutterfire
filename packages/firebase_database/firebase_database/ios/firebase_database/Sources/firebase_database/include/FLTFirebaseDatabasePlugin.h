// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
@import FirebaseDatabase;
#endif

#import <Foundation/Foundation.h>
@import firebase_core;

@interface FLTFirebaseDatabasePlugin : NSObject <FlutterPlugin, FLTFirebasePlugin>
@end
