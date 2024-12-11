// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebaseFirestore;
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import "include/cloud_firestore/Private/FLTFirebaseFirestoreUtils.h"
#import "include/cloud_firestore/Private/FLTTransactionStreamHandler.h"
#import "include/cloud_firestore/Private/FirestorePigeonParser.h"

@interface FLTTransactionStreamHandler ()
@property(nonatomic, copy, nonnull) void (^started)(FIRTransaction *);
@property(nonatomic, copy, nonnull) void (^ended)(void);
@property(strong) dispatch_semaphore_t semaphore;
@property PigeonTransactionResult resultType;
@property NSArray<PigeonTransactionCommand *> *commands;

@end

@implementation FLTTransactionStreamHandler {
  NSString *_transactionId;
}

- (instancetype)initWithId:(NSString *)transactionId
                 firestore:(FIRFirestore *)firestore
                   timeout:(nonnull NSNumber *)timeout
               maxAttempts:(nonnull NSNumber *)maxAttempts
                   started:(void (^)(FIRTransaction *))startedListener
                     ended:(void (^)(void))endedListener {
  self = [super init];
  if (self) {
    _transactionId = transactionId;
    self.firestore = firestore;
    self.maxAttempts = maxAttempts;
    self.timeout = timeout;
    self.started = startedListener;
    self.ended = endedListener;
    self.semaphore = dispatch_semaphore_create(0);
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  __weak FLTTransactionStreamHandler *weakSelf = self;

  id transactionRunBlock = ^id(FIRTransaction *transaction, NSError **pError) {
    FLTTransactionStreamHandler *strongSelf = weakSelf;

    strongSelf.started(transaction);

    dispatch_async(dispatch_get_main_queue(), ^{
      events(
          @{@"appName" : [FLTFirebasePlugin firebaseAppNameFromIosName:self.firestore.app.name]});
    });

    long timedOut = dispatch_semaphore_wait(
        strongSelf.semaphore,
        dispatch_time(DISPATCH_TIME_NOW, [self.timeout integerValue] * NSEC_PER_MSEC));

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

    if (self.resultType == PigeonTransactionResultFailure) {
      // Do nothing - already handled in Dart land.
      return nil;
    }

    for (PigeonTransactionCommand *command in self.commands) {
      PigeonTransactionType commandType = command.type;
      NSString *documentPath = command.path;
      FIRDocumentReference *reference = [self.firestore documentWithPath:documentPath];

      switch (commandType) {
        case PigeonTransactionTypeDeleteType:
          [transaction deleteDocument:reference];
          break;
        case PigeonTransactionTypeUpdate:
          [transaction updateData:command.data forDocument:reference];
          break;
        case PigeonTransactionTypeSet:
          if ([command.option.merge isEqual:@YES]) {
            [transaction setData:command.data forDocument:reference merge:YES];
          } else if (command.option.mergeFields) {
            [transaction setData:command.data
                     forDocument:reference
                     mergeFields:[FirestorePigeonParser parseFieldPath:command.option.mergeFields]];
          } else {
            [transaction setData:command.data forDocument:reference];
          }
          break;
        default:
          break;
      }
    }

    return nil;
  };

  id transactionCompleteBlock = ^(id transactionResult, NSError *error) {
    FLTTransactionStreamHandler *strongSelf = weakSelf;
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

    strongSelf.ended();
  };
  FIRTransactionOptions *options = [[FIRTransactionOptions alloc] init];
  options.maxAttempts = _maxAttempts.integerValue;

  [_firestore runTransactionWithOptions:options
                                  block:transactionRunBlock
                             completion:transactionCompleteBlock];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  dispatch_semaphore_signal(self.semaphore);

  return nil;
}

- (void)receiveTransactionResponse:(PigeonTransactionResult)resultType
                          commands:(NSArray<PigeonTransactionCommand *> *)commands {
  self.resultType = resultType;
  self.commands = commands;

  dispatch_semaphore_signal(self.semaphore);
}

@end
