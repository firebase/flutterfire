// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#if TARGET_OS_OSX
#import <FirebaseDatabase/FirebaseDatabase.h>
#else
@import FirebaseDatabase;
#endif
#import <Foundation/Foundation.h>

@interface FLTFirebaseDatabaseUtils : NSObject

+ (dispatch_queue_t)dispatchQueue;
+ (FIRDatabase *)databaseFromArguments:(id)arguments;
+ (FIRDatabaseReference *)databaseReferenceFromArguments:(id)arguments;
+ (FIRDatabaseQuery *)databaseQueryFromArguments:(id)arguments;
+ (NSDictionary *)dictionaryFromSnapshot:(FIRDataSnapshot *)snapshot
                    withPreviousChildKey:(NSString *)previousChildName;
+ (NSDictionary *)dictionaryFromSnapshot:(FIRDataSnapshot *)snapshot;
+ (NSArray *)codeAndMessageFromNSError:(NSError *)error;
+ (FIRDataEventType)eventTypeFromString:(NSString *)eventTypeString;

@end
