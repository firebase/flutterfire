// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <Firebase/Firebase.h>
#import <Flutter/Flutter.h>
#import <firebase_core/FLTFirebasePlugin.h>

@interface FLTFirebaseDynamicLinksPlugin : FLTFirebasePlugin <FlutterPlugin, FLTFirebasePlugin>

@property(nonatomic, retain) NSError *initialError;
@property(nonatomic, retain) NSObject<FlutterBinaryMessenger> *messenger;
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic, retain) FIRDynamicLink *initialLink;
@property(nonatomic, retain) FIRDynamicLink *latestLink;
@property(nonatomic) BOOL initiated;
@end
