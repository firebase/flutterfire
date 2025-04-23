// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#import <Flutter/Flutter.h> // Needed for FlutterError

NS_ASSUME_NONNULL_BEGIN

@interface FLTFirebaseRemoteConfigUtils : NSObject
+ (NSDictionary *)ErrorCodeAndMessageFromNSError:(NSError *)error;
// Add helper to create FlutterError from NSError for Pigeon completion blocks
+ (FlutterError * _Nullable)flutterErrorFromNSError:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
