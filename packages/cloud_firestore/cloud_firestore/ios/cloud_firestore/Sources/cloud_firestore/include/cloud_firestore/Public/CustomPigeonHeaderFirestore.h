// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "FirestoreMessages.g.h"

@interface InternalDocumentSnapshot (Map)
- (NSDictionary *)toList;
@end

@interface InternalDocumentChange (Map)
- (NSDictionary *)toList;
@end

@interface InternalSnapshotMetadata (Map)
- (NSDictionary *)toList;
@end
