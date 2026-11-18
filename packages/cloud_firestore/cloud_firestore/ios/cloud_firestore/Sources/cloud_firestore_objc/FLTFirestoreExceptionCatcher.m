// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirestoreExceptionCatcher.h"

@implementation FLTFirestoreExceptionCatcher

+ (NSError *_Nullable)perform:(void(NS_NOESCAPE ^)(void))block {
  @try {
    block();
    return nil;
  } @catch (NSException *exception) {
    NSLog(@"An error occurred while parsing query arguments, this is most likely an error with "
          @"this SDK. %@",
          [exception callStackSymbols]);
    NSString *reason = exception.reason ?: exception.name;
    return [NSError errorWithDomain:@"FLTFirebaseFirestore"
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey : reason ?: @""}];
  }
}

@end
