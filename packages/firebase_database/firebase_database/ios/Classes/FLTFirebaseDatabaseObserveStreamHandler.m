// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "FLTFirebaseDatabaseObserveStreamHandler.h"
#import "FLTFirebaseDatabaseUtils.h"

@interface FLTFirebaseDatabaseObserveStreamHandler ()
@property(readwrite) FIRDatabaseHandle databaseHandle;
@property(readonly) FIRDatabaseQuery *databaseQuery;
@property(readwrite) void (^disposeBlock)(void);
@end

@implementation FLTFirebaseDatabaseObserveStreamHandler

- (instancetype)initWithFIRDatabaseQuery:(FIRDatabaseQuery *)databaseQuery
                       andOnDisposeBlock:(void (^)(void))disposeBlock {
  self = [super init];
  if (self) {
    _databaseQuery = databaseQuery;
    _disposeBlock = disposeBlock;
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  NSString *eventTypeString = arguments[@"eventType"];
  id observeBlock = ^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
    NSMutableDictionary *eventDictionary = [@{
      @"eventType" : eventTypeString,
    } mutableCopy];
    [eventDictionary addEntriesFromDictionary:[FLTFirebaseDatabaseUtils
                                                  dictionaryFromSnapshot:snapshot
                                                    withPreviousChildKey:previousChildKey]];
    dispatch_async(dispatch_get_main_queue(), ^{
      events(eventDictionary);
    });
  };

  id cancelBlock = ^(NSError *error) {
    NSArray *codeAndMessage = [FLTFirebaseDatabaseUtils codeAndMessageFromNSError:error];
    NSString *code = codeAndMessage[0];
    NSString *message = codeAndMessage[1];
    NSDictionary *details = @{
      @"code" : code,
      @"message" : message,
    };
    dispatch_async(dispatch_get_main_queue(), ^{
      events([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                   message:message
                                           optionalDetails:details
                                        andOptionalNSError:error]);
    });
  };

  _databaseHandle = [_databaseQuery
                    observeEventType:[FLTFirebaseDatabaseUtils eventTypeFromString:eventTypeString]
      andPreviousSiblingKeyWithBlock:observeBlock
                     withCancelBlock:cancelBlock];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _disposeBlock();
  [_databaseQuery removeObserverWithHandle:_databaseHandle];
  return nil;
}

@end
