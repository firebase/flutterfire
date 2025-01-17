// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "firebase_auth_messages.g.h"

@interface PigeonMultiFactorInfo (Map)
- (NSDictionary *)toList;
@end

@interface PigeonUserDetails (Map)
- (NSDictionary *)toList;
@end

@interface PigeonUserInfo (Map)
- (NSDictionary *)toList;
@end
