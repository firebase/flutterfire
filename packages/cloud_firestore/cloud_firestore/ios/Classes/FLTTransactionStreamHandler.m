// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Private/FLTTransactionStreamHandler.h"

@interface FLTTransactionStreamHandler ()
@property(nonatomic, copy, nonnull) void (^started)(FIRTransaction *);
@property(nonatomic, copy, nonnull) void (^ended)(void);
@end

@implementation FLTTransactionStreamHandler {
  NSString *_transactionId;
  dispatch_semaphore_t _semaphore;
  NSDictionary *_response;
}

- (instancetype)initWithId:(NSString *)transactionId
                   started:(void (^)(FIRTransaction *))startedListener
                     ended:(void (^)(void))endedListener {
  self = [super init];
  if (self) {
    _transactionId = transactionId;
    self.started = startedListener;
    self.ended = endedListener;
    _semaphore = dispatch_semaphore_create(0);
    _response = [NSMutableDictionary dictionary];
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  FIRFirestore *firestore = arguments[@"firestore"];
  NSNumber *transactionTimeout = arguments[@"timeout"];

  id transactionRunBlock = ^id(FIRTransaction *transaction, NSError **pError) {
    self.started(transaction);

    dispatch_async(dispatch_get_main_queue(), ^{
      events(@{@"appName" : [FLTFirebasePlugin firebaseAppNameFromIosName:firestore.app.name]});
    });

    long timedOut = dispatch_semaphore_wait(
        self->_semaphore,
        dispatch_time(DISPATCH_TIME_NOW, [transactionTimeout integerValue] * NSEC_PER_MSEC));

    if (timedOut) {
      NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils
          ErrorCodeAndMessageFromNSError:[NSError
                                             errorWithDomain:FIRFirestoreErrorDomain
                                                        code:FIRFirestoreErrorCodeDeadlineExceeded
                                                    userInfo:@{}]];

      dispatch_async(dispatch_get_main_queue(), ^{
        events(@{
          @"error" : @{
            @"code" : codeAndMessage[0],
            @"message" : codeAndMessage[1],
          }
        });
      });
    }

    NSDictionary *response = self->_response;

    if (response.count == 0) {
      return nil;
    }

    NSString *dartResponseType = response[@"type"];

    if ([@"ERROR" isEqualToString:dartResponseType]) {
      // Do nothing - already handled in Dart land.
      return nil;
    }

    NSArray<NSDictionary *> *commands = response[@"commands"];
    for (NSDictionary *command in commands) {
      NSString *commandType = command[@"type"];
      NSString *documentPath = command[@"path"];
      FIRDocumentReference *reference = [firestore documentWithPath:documentPath];
      if ([@"DELETE" isEqualToString:commandType]) {
        [transaction deleteDocument:reference];
      } else if ([@"UPDATE" isEqualToString:commandType]) {
        NSDictionary *data = command[@"data"];
        [transaction updateData:data forDocument:reference];
      } else if ([@"SET" isEqualToString:commandType]) {
        NSDictionary *data = command[@"data"];
        NSDictionary *options = command[@"options"];
        if ([options[@"merge"] isEqual:@YES]) {
          [transaction setData:data forDocument:reference merge:YES];
        } else if (![options[@"mergeFields"] isEqual:[NSNull null]]) {
          [transaction setData:data forDocument:reference mergeFields:options[@"mergeFields"]];
        } else {
          [transaction setData:data forDocument:reference];
        }
      }
    }

    return nil;
  };

  id transactionCompleteBlock = ^(id transactionResult, NSError *error) {
    if (error) {
      NSArray *details = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];

      dispatch_async(dispatch_get_main_queue(), ^{
        events(@{
          @"error" : @{
            @"code" : details[0],
            @"message" : details[1],
          }
        });
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        events(@{@"complete" : [NSNumber numberWithBool:YES]});
      });
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      events(FlutterEndOfEventStream);
    });

    self.ended();
  };

  [firestore runTransactionWithBlock:transactionRunBlock completion:transactionCompleteBlock];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  dispatch_semaphore_signal(_semaphore);

  return nil;
}

- (void)receiveTransactionResponse:(NSDictionary *)response {
  _response = response;

  dispatch_semaphore_signal(_semaphore);
}

@end
