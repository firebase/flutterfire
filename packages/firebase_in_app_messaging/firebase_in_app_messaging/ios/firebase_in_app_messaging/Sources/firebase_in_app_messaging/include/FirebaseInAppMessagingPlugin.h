// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <TargetConditionals.h>

#import <Foundation/Foundation.h>
#if __has_include(<firebase_core_shared/firebase_core_shared-Swift.h>)
@import firebase_core_shared;
#else
@import firebase_core;
#endif

@interface FirebaseInAppMessagingPlugin : NSObject <FlutterPlugin, FLTFirebasePlugin>
@end
