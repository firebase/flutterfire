// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <Firebase/Firebase.h>
#import "FirestoreMessages.g.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTTransactionStreamHandler : NSObject <FlutterStreamHandler>
@property(nonatomic, strong) FIRFirestore *firestore;
@property(nonatomic, strong) NSNumber *timeout;
@property(nonatomic, strong) NSNumber *maxAttempts;

- (instancetype)initWithId:(NSString *)transactionId
                 firestore:(FIRFirestore *)firestore
                   timeout:(nonnull NSNumber *)timeout
               maxAttempts:(nonnull NSNumber *)maxAttempts
                   started:(void (^)(FIRTransaction *))startedListener
                     ended:(void (^)(void))endedListener;
- (void)receiveTransactionResponse:(PigeonTransactionResult)resultType
                          commands:(NSArray<PigeonTransactionCommand *> *)commands;

@end

NS_ASSUME_NONNULL_END
