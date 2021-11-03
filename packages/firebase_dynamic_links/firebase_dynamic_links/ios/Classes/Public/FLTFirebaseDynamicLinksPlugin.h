// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

@interface FLTFirebaseDynamicLinksPlugin : FLTFirebasePlugin <FlutterPlugin, FLTFirebasePlugin>

@property(nonatomic, retain) FlutterError *flutterError;
@property(nonatomic, retain) NSObject<FlutterBinaryMessenger> *messenger;
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic, retain) FIRDynamicLink *initialLink;
@property(nonatomic, retain) FIRDynamicLink *latestLink;
@property(nonatomic) BOOL initiated;
@end
