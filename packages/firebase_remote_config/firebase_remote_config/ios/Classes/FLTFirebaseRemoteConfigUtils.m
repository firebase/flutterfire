// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>

#import "FLTFirebaseRemoteConfigUtils.h"

@implementation FLTFirebaseRemoteConfigUtils
+ (NSDictionary *)ErrorCodeAndMessageFromNSError:(NSError *)error {
  NSMutableDictionary *codeAndMessage = [[NSMutableDictionary alloc] init];
  switch (error.code) {
    case FIRRemoteConfigErrorInternalError:
      if ([error.userInfo[NSLocalizedDescriptionKey] containsString:@"403"]) {
        // See PR for details: https://github.com/firebase/flutterfire/pull/9629
        [codeAndMessage setValue:@"forbidden" forKey:@"code"];
        NSString *updateMessage =
            [NSString stringWithFormat:@"%@%@", error.userInfo[NSLocalizedDescriptionKey],
                                       @". You may have to enable the Remote Config API on Google "
                                       @"Cloud Platform for your Firebase project."];
        [codeAndMessage setValue:updateMessage forKey:@"message"];
      } else {
        [codeAndMessage setValue:@"internal" forKey:@"code"];
        [codeAndMessage setValue:error.userInfo[NSLocalizedDescriptionKey] forKey:@"message"];
      }
      break;
    case FIRRemoteConfigErrorThrottled:
      [codeAndMessage setValue:@"throttled" forKey:@"code"];
      [codeAndMessage setValue:@"frequency of requests exceeds throttled limits" forKey:@"message"];
      break;
    default:
      [codeAndMessage setValue:@"unknown" forKey:@"code"];
      [codeAndMessage setValue:@"unknown remote config error" forKey:@"message"];
      break;
  }
  return codeAndMessage;
}
@end
