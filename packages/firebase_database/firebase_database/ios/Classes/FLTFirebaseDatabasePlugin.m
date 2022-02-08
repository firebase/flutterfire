// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "FLTFirebaseDatabaseObserveStreamHandler.h"
#import "FLTFirebaseDatabasePlugin.h"
#import "FLTFirebaseDatabaseUtils.h"

NSString *const kFLTFirebaseDatabaseChannelName = @"plugins.flutter.io/firebase_database";

@implementation FLTFirebaseDatabasePlugin {
  // Used by FlutterStreamHandlers.
  NSObject<FlutterBinaryMessenger> *_binaryMessenger;
  NSMutableDictionary<NSString *, FLTFirebaseDatabaseObserveStreamHandler *> *_streamHandlers;
  // Used by transactions.
  FlutterMethodChannel *_channel;
  int _listenerCount;
}

#pragma mark - FlutterPlugin

- (instancetype)init:(NSObject<FlutterBinaryMessenger> *)messenger
          andChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
    _binaryMessenger = messenger;
    _streamHandlers = [NSMutableDictionary dictionary];
    _listenerCount = 0;
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseDatabaseChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseDatabasePlugin *instance =
      [[FLTFirebaseDatabasePlugin alloc] init:[registrar messenger] andChannel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
  [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];

#if TARGET_OS_OSX
  // Publish does not exist on MacOS version of FlutterPluginRegistrar.
#else
  [registrar publish:instance];
#endif
}

- (void)cleanupWithCompletion:(void (^)(void))completion {
  for (NSString *handlerId in self->_streamHandlers) {
    NSObject<FlutterStreamHandler> *handler = self->_streamHandlers[handlerId];
    [handler onCancelWithArguments:nil];
  }
  [self->_streamHandlers removeAllObjects];
  if (completion != nil) {
    completion();
  }
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self cleanupWithCompletion:nil];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        if (code == nil) {
          NSArray *codeAndErrorMessage = [FLTFirebaseDatabaseUtils codeAndMessageFromNSError:error];
          code = codeAndErrorMessage[0];
          message = codeAndErrorMessage[1];
          details = @{
            @"code" : code,
            @"message" : message,
          };
        }
        if ([@"unknown" isEqualToString:code]) {
          NSLog(@"FLTFirebaseDatabase: An error occurred while calling method %@", call.method);
        }
        flutterResult([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                            message:message
                                                    optionalDetails:details
                                                 andOptionalNSError:error]);
      };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([@"FirebaseDatabase#goOnline" isEqualToString:call.method]) {
    [self databaseGoOnline:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebaseDatabase#goOffline" isEqualToString:call.method]) {
    [self databaseGoOffline:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebaseDatabase#purgeOutstandingWrites" isEqualToString:call.method]) {
    [self databasePurgeOutstandingWrites:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DatabaseReference#set" isEqualToString:call.method]) {
    [self databaseSet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DatabaseReference#setWithPriority" isEqualToString:call.method]) {
    [self databaseSetWithPriority:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DatabaseReference#update" isEqualToString:call.method]) {
    [self databaseUpdate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DatabaseReference#setPriority" isEqualToString:call.method]) {
    [self databaseSetPriority:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DatabaseReference#runTransaction" isEqualToString:call.method]) {
    [self databaseRunTransaction:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"OnDisconnect#set" isEqualToString:call.method]) {
    [self onDisconnectSet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"OnDisconnect#setWithPriority" isEqualToString:call.method]) {
    [self onDisconnectSetWithPriority:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"OnDisconnect#update" isEqualToString:call.method]) {
    [self onDisconnectUpdate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"OnDisconnect#cancel" isEqualToString:call.method]) {
    [self onDisconnectCancel:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Query#get" isEqualToString:call.method]) {
    [self queryGet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Query#keepSynced" isEqualToString:call.method]) {
    [self queryKeepSynced:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Query#observe" isEqualToString:call.method]) {
    [self queryObserve:call.arguments withMethodCallResult:methodCallResult];
  } else {
    methodCallResult.success(FlutterMethodNotImplemented);
  }
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  [self cleanupWithCompletion:completion];
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  return @{};
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseDatabaseChannelName;
}

#pragma mark - Database API

- (void)databaseGoOnline:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabase *database = [FLTFirebaseDatabaseUtils databaseFromArguments:arguments];
  [database goOnline];
  result.success(nil);
}

- (void)databaseGoOffline:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabase *database = [FLTFirebaseDatabaseUtils databaseFromArguments:arguments];
  [database goOffline];
  result.success(nil);
}

- (void)databasePurgeOutstandingWrites:(id)arguments
                  withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabase *database = [FLTFirebaseDatabaseUtils databaseFromArguments:arguments];
  [database purgeOutstandingWrites];
  result.success(nil);
}

- (void)databaseSet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference setValue:arguments[@"value"]
      withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (error != nil) {
          result.error(nil, nil, nil, error);
        } else {
          result.success(nil);
        }
      }];
}

- (void)databaseSetWithPriority:(id)arguments
           withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference setValue:arguments[@"value"]
              andPriority:arguments[@"priority"]
      withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (error != nil) {
          result.error(nil, nil, nil, error);
        } else {
          result.success(nil);
        }
      }];
}

- (void)databaseUpdate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference updateChildValues:arguments[@"value"]
           withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
             if (error != nil) {
               result.error(nil, nil, nil, error);
             } else {
               result.success(nil);
             }
           }];
}

- (void)databaseSetPriority:(id)arguments
       withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference setPriority:arguments[@"priority"]
      withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (error != nil) {
          result.error(nil, nil, nil, error);
        } else {
          result.success(nil);
        }
      }];
}

- (void)databaseRunTransaction:(id)arguments
          withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  int transactionKey = [arguments[@"transactionKey"] intValue];
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];

  __weak FLTFirebaseDatabasePlugin *weakSelf = self;
  [reference
      runTransactionBlock:^FIRTransactionResult *(FIRMutableData *currentData) {
        __strong FLTFirebaseDatabasePlugin *strongSelf = weakSelf;
        // Create semaphore to allow native side to wait while updates occur on the Dart side.
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        // Whether the transaction was aborted in Dart by the user or by a Dart exception
        // occurring.
        __block bool aborted = false;
        // Whether an exception occurred in users Dart transaction handler.
        __block bool exception = false;

        id methodCallResultHandler = ^(id _Nullable result) {
          aborted = [result[@"aborted"] boolValue];
          exception = [result[@"exception"] boolValue];
          currentData.value = result[@"value"];
          dispatch_semaphore_signal(semaphore);
        };

        [strongSelf->_channel invokeMethod:@"FirebaseDatabase#callTransactionHandler"
                                 arguments:@{
                                   @"transactionKey" : @(transactionKey),
                                   @"snapshot" : @{
                                     @"key" : currentData.key ?: [NSNull null],
                                     @"value" : currentData.value ?: [NSNull null],
                                   }
                                 }
                                    result:methodCallResultHandler];
        // Wait while Dart side updates the value.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        if (aborted || exception) {
          return [FIRTransactionResult abort];
        }
        return [FIRTransactionResult successWithValue:currentData];
      }
      andCompletionBlock:^(NSError *error, BOOL committed, FIRDataSnapshot *snapshot) {
        if (error != nil) {
          result.error(nil, nil, nil, error);
        } else {
          result.success(@{
            @"committed" : @(committed),
            @"snapshot" : [FLTFirebaseDatabaseUtils dictionaryFromSnapshot:snapshot],
          });
        }
      }
      withLocalEvents:[arguments[@"transactionApplyLocally"] boolValue]];
}

- (void)onDisconnectSet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference onDisconnectSetValue:arguments[@"value"]
              withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
                if (error != nil) {
                  result.error(nil, nil, nil, error);
                } else {
                  result.success(nil);
                }
              }];
}

- (void)onDisconnectSetWithPriority:(id)arguments
               withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference onDisconnectSetValue:arguments[@"value"]
                      andPriority:arguments[@"priority"]
              withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
                if (error != nil) {
                  result.error(nil, nil, nil, error);
                } else {
                  result.success(nil);
                }
              }];
}

- (void)onDisconnectUpdate:(id)arguments
      withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference onDisconnectUpdateChildValues:arguments[@"value"]
                       withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
                         if (error != nil) {
                           result.error(nil, nil, nil, error);
                         } else {
                           result.success(nil);
                         }
                       }];
}

- (void)onDisconnectCancel:(id)arguments
      withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseReference *reference =
      [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  [reference
      cancelDisconnectOperationsWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (error != nil) {
          result.error(nil, nil, nil, error);
        } else {
          result.success(nil);
        }
      }];
}

- (void)queryGet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseQuery *query = [FLTFirebaseDatabaseUtils databaseQueryFromArguments:arguments];
  [query getDataWithCompletionBlock:^(NSError *error, FIRDataSnapshot *snapshot) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else
      result.success(@{
        @"snapshot" : [FLTFirebaseDatabaseUtils dictionaryFromSnapshot:snapshot],
      });
  }];
}

- (void)queryKeepSynced:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseQuery *query = [FLTFirebaseDatabaseUtils databaseQueryFromArguments:arguments];
  [query keepSynced:[arguments[@"value"] boolValue]];
  result.success(nil);
}

- (void)queryObserve:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDatabaseQuery *databaseQuery = [FLTFirebaseDatabaseUtils databaseQueryFromArguments:arguments];
  NSString *eventChannelNamePrefix = arguments[@"eventChannelNamePrefix"];
  _listenerCount = _listenerCount + 1;
  NSString *eventChannelName =
      [NSString stringWithFormat:@"%@#%i", eventChannelNamePrefix, _listenerCount];

  FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName
                                                                binaryMessenger:_binaryMessenger];
  FLTFirebaseDatabaseObserveStreamHandler *streamHandler =
      [[FLTFirebaseDatabaseObserveStreamHandler alloc] initWithFIRDatabaseQuery:databaseQuery
                                                              andOnDisposeBlock:^() {
                                                                [eventChannel setStreamHandler:nil];
                                                              }];
  [eventChannel setStreamHandler:streamHandler];
  _streamHandlers[eventChannelName] = streamHandler;
  result.success(eventChannelName);
}

@end
