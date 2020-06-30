// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

@interface FirebaseMLPlugin : NSObject <FlutterPlugin>
@end

@interface ModelManager : NSObject
+ (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
@end