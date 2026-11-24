// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTFirestoreExceptionCatcher : NSObject
// Firestore raises NSException for invalid queries. Swift do/catch does not
// catch those, so this runs the block in Objective-C.
+ (NSError *_Nullable)perform:(void(NS_NOESCAPE ^)(void))block;
@end

NS_ASSUME_NONNULL_END
