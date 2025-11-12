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
#if __has_include(<firebase_core/firebase_core.h>)
@import firebase_core;
#else
@import firebase_core_shared;
#endif
#import "FLTAppCheckProviderFactory.h"

@interface FLTFirebaseAppCheckPlugin : NSObject <FlutterPlugin, FLTFirebasePlugin>
@end
