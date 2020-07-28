// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

/** A flutter plugin for accessing the Firebase ML APIs for custom models. */
@interface FLTFirebaseMLCustomPlugin : NSObject <FlutterPlugin>
+ (void)handleError:(NSError *)error result:(FlutterResult)result;
@end

/**
 * A delegate for FLTFirebaseMLCustomPlugin to handle management of remote models.
 */
@interface FLTModelManager : NSObject

/** Chooses appropriate FIRModelManager API based on the method call. */
+ (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
@end
