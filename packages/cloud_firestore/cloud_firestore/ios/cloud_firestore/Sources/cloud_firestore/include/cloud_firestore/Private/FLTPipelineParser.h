/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#import <Foundation/Foundation.h>

@class FIRFirestore;

NS_ASSUME_NONNULL_BEGIN

@interface FLTPipelineParser : NSObject

+ (void)executePipelineWithFirestore:(FIRFirestore *)firestore
                              stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                             options:(nullable NSDictionary<NSString *, id> *)options
                          completion:
                              (void (^)(id _Nullable snapshot, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
