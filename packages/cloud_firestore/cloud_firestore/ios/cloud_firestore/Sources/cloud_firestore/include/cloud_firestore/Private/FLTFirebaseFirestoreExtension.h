// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <FirebaseFirestore/FirebaseFirestore.h>
#import <Foundation/Foundation.h>

@interface FLTFirebaseFirestoreExtension : NSObject

@property(nonatomic, strong, readonly) FIRFirestore *instance;
@property(nonatomic, strong, readonly) NSString *databaseURL;

- (instancetype)initWithFirestoreInstance:(FIRFirestore *)instance
                              databaseURL:(NSString *)databaseURL;

@end
