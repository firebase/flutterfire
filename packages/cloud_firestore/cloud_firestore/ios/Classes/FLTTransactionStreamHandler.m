//
//  FLTTransactionStreamHandler.m
//  cloud_firestore
//
//  Created by Sebastian Roth on 24/11/2020.
//

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTTransactionStreamHandler.h"
#import "Private/FLTFirebaseFirestoreUtils.h"

@implementation FLTTransactionStreamHandler {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
  NSMutableDictionary<NSNumber *, FIRTransaction *> *_transactions;
  NSMutableDictionary<NSNumber *, dispatch_semaphore_t> *_semaphores;
  NSMutableDictionary<NSNumber *, NSDictionary*> *_attemptedTransactionResponses;
}

-(instancetype) init:(NSMutableDictionary<NSNumber *,FIRTransaction *> *)transactions {
  self = [super init];
  if (self) {
    _listeners = [NSMutableDictionary dictionary];
    _transactions = transactions;
    _semaphores = [NSMutableDictionary dictionary];
    _attemptedTransactionResponses = [NSMutableDictionary dictionary];
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  
  FIRFirestore *firestore = arguments[@"firestore"];
  NSNumber *transactionId = arguments[@"transactionId"];
  NSNumber *transactionTimeout = arguments[@"timeout"];

  NSDictionary *transactionAttemptArguments = @{
    @"transactionId" : transactionId,
    @"appName" : [FLTFirebasePlugin firebaseAppNameFromIosName:firestore.app.name]
  };

  id transactionRunBlock = ^id(FIRTransaction *transaction, NSError **pError) {
    @synchronized(self->_transactions) {
      self->_transactions[transactionId] = transaction;
    }

    @synchronized (self->_semaphores) {
      self->_semaphores[transactionId] = dispatch_semaphore_create(0);
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      events(@{ @"attempt": transactionAttemptArguments });
      
//      [weakSelf.channel invokeMethod:@"Transaction#attempt"
//                           arguments:transactionAttemptArguments
//                              result:^(id dartAttemptTransactionResult) {
//                                attemptedTransactionResponse = dartAttemptTransactionResult;
//                                dispatch_semaphore_signal(semaphore);
//                              }];
    });

    long timedOut = dispatch_semaphore_wait(
        self->_semaphores[transactionId],
        dispatch_time(DISPATCH_TIME_NOW, [transactionTimeout integerValue] * NSEC_PER_MSEC));
    
    if (timedOut) {
      *pError = [NSError errorWithDomain:FIRFirestoreErrorDomain
                                    code:FIRFirestoreErrorCodeDeadlineExceeded
                                userInfo:@{}];
      return nil;
    }

    NSDictionary *attemptedTransactionResponse = self->_attemptedTransactionResponses[transactionId];
    NSString *dartResponseType =
        attemptedTransactionResponse ? attemptedTransactionResponse[@"type"] : @"ERROR";

    if ([@"ERROR" isEqualToString:dartResponseType]) {
      // Do nothing - already handled in Dart land.
      return nil;
    }

    NSArray<NSDictionary *> *commands = attemptedTransactionResponse[@"commands"];
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
    @synchronized(self->_transactions) {
      [self->_transactions removeObjectForKey:transactionId];
    }
  };

  [firestore runTransactionWithBlock:transactionRunBlock completion:transactionCompleteBlock];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
//  NSNumber *handle = arguments[@"handle"];
//
//  @synchronized(_listeners) {
//    [_listeners[handle] remove];
//    [_listeners removeObjectForKey:handle];
//  }

  return nil;
}

- (void)receiveTransactionResponse:(NSNumber *)transactionId response:(NSDictionary *)response {
  _attemptedTransactionResponses[transactionId] = response;

  @synchronized (_semaphores) {
    dispatch_semaphore_signal(_semaphores[transactionId]);
  }
}

@end
