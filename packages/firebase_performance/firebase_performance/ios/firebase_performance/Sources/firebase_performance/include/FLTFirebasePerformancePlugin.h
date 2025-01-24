// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebasePerformance;
#import <Flutter/Flutter.h>
#import <TargetConditionals.h>
#if __has_include(<firebase_core/FLTFirebasePlugin.h>)
#import <firebase_core/FLTFirebasePlugin.h>
#else
#import <FLTFirebasePlugin.h>
#endif

@interface FLTFirebasePerformancePlugin : FLTFirebasePlugin <FlutterPlugin, FLTFirebasePlugin>

@end
