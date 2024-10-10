// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@import FirebaseFirestore;

#import "include/cloud_firestore/Private/FLTFirebaseFirestoreExtension.h"

@interface FLTFirebaseFirestoreExtension ()

@property(nonatomic, strong, readwrite) FIRFirestore *instance;
@property(nonatomic, strong, readwrite) NSString *databaseURL;

@end

@implementation FLTFirebaseFirestoreExtension

- (instancetype)initWithFirestoreInstance:(FIRFirestore *)firestore
                              databaseURL:(NSString *)databaseURL {
  self = [super init];
  if (self) {
    _instance = firestore;
    _databaseURL = [databaseURL copy];
  }
  return self;
}

@end
