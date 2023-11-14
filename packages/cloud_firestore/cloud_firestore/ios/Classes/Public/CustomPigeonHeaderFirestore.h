// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "FirestoreMessages.g.h"

@interface PigeonDocumentSnapshot (Map)
- (NSDictionary *)toList;
@end

@interface PigeonDocumentChange (Map)
- (NSDictionary *)toList;
@end

@interface PigeonSnapshotMetadata (Map)
- (NSDictionary *)toList;
@end
