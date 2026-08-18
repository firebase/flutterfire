// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "firebase_auth_messages.g.h"

@interface InternalMultiFactorInfo (Map)
- (NSDictionary *)toList;
@end

@interface InternalUserDetails (Map)
- (NSDictionary *)toList;
@end

@interface InternalUserInfo (Map)
- (NSDictionary *)toList;
@end
