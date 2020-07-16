// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Public/FLTFirebaseFirestorePlugin.h"

NSString *const kFLTFirebaseFirestoreChannelName = @"plugins.flutter.io/firebase_firestore";

@interface FLTFirebaseFirestorePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTFirebaseFirestorePlugin {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
  NSMutableDictionary *_transactions;
}

#pragma mark - FlutterPlugin

// Returns a singleton instance of the Firebase Firestore plugin.
+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebaseFirestorePlugin *instance;

  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebaseFirestorePlugin alloc] init];
    // Register with the Flutter Firebase plugin registry.
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
  });

  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _listeners = [NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> dictionary];
    _transactions = [NSMutableDictionary<NSNumber *, FIRTransaction *> dictionary];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFirebaseFirestoreReaderWriter *firestoreReaderWriter = [FLTFirebaseFirestoreReaderWriter new];
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseFirestoreChannelName
                                  binaryMessenger:[registrar messenger]
                                            codec:[FlutterStandardMethodCodec
                                                      codecWithReaderWriter:firestoreReaderWriter]];

  FLTFirebaseFirestorePlugin *instance = [FLTFirebaseFirestorePlugin sharedInstance];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
#if TARGET_OS_OSX
// TODO(Salakar): Publish does not exist on MacOS version of FlutterPluginRegistrar.
#else
  [registrar publish:instance];
#endif
}

- (void)cleanupWithCompletion:(void (^)(void))completion {
  @synchronized(self->_listeners) {
    for (NSNumber *key in [self->_listeners allKeys]) {
      id<FIRListenerRegistration> listener = self->_listeners[key];
      [listener remove];
    }
    [self->_listeners removeAllObjects];
  }

  @synchronized(self->_transactions) {
    [self->_transactions removeAllObjects];
  }

  __block int instancesTerminated = 0;
  NSUInteger numberOfApps = [[FIRApp allApps] count];
  void (^firestoreTerminateInstanceCompletion)(NSError *) = ^void(NSError *error) {
    instancesTerminated++;
    if (instancesTerminated == numberOfApps && completion != nil) {
      completion();
    }
  };

  if (numberOfApps > 0) {
    for (NSString *appName in [FIRApp allApps]) {
      FIRApp *app = [FIRApp appNamed:appName];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[FIRFirestore firestoreForApp:app] terminateWithCompletion:^(NSError *error) {
          [FLTFirebaseFirestoreUtils destroyCachedFIRFirestoreInstanceForKey:appName];
          firestoreTerminateInstanceCompletion(error);
        }];
      });
    }
  } else {
    if (completion != nil) completion();
  }
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self cleanupWithCompletion:nil];
  self.channel = nil;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock = ^(
      NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
      NSError *_Nullable error) {
    if (code == nil) {
      NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];
      code = codeAndMessage[0];
      message = codeAndMessage[1];
      details = @{
        @"code" : code,
        @"message" : message,
      };
    }
    if ([@"unknown" isEqualToString:code]) {
      NSLog(@"FLTFirebaseFirestore: An error occurred while calling method %@", call.method);
    }
    flutterResult([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                        message:message
                                                optionalDetails:details
                                             andOptionalNSError:error]);
  };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([@"Transaction#create" isEqualToString:call.method]) {
    [self transactionCreate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Transaction#get" isEqualToString:call.method]) {
    [self transactionGet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#set" isEqualToString:call.method]) {
    [self documentSet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#update" isEqualToString:call.method]) {
    [self documentUpdate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#delete" isEqualToString:call.method]) {
    [self documentDelete:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#get" isEqualToString:call.method]) {
    [self documentGet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Query#addSnapshotListener" isEqualToString:call.method]) {
    [self queryAddSnapshotListener:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#addSnapshotListener" isEqualToString:call.method]) {
    [self documentAddSnapshotListener:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Query#get" isEqualToString:call.method]) {
    [self queryGet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Firestore#removeListener" isEqualToString:call.method]) {
    [self removeListener:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"WriteBatch#commit" isEqualToString:call.method]) {
    [self batchCommit:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Firestore#terminate" isEqualToString:call.method]) {
    [self terminate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Firestore#enableNetwork" isEqualToString:call.method]) {
    [self enableNetwork:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Firestore#disableNetwork" isEqualToString:call.method]) {
    [self disableNetwork:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Firestore#clearPersistence" isEqualToString:call.method]) {
    [self clearPersistence:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Firestore#waitForPendingWrites" isEqualToString:call.method]) {
    [self waitForPendingWrites:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Firestore#addSnapshotsInSyncListener" isEqualToString:call.method]) {
    [self addSnapshotsInSyncListener:call.arguments withMethodCallResult:methodCallResult];
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
  return kFLTFirebaseFirestoreChannelName;
}

#pragma mark - Firestore API

- (void)addSnapshotsInSyncListener:(id)arguments
              withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  __weak __typeof__(self) weakSelf = self;
  NSNumber *handle = arguments[@"handle"];
  FIRFirestore *firestore = arguments[@"firestore"];

  id listener = ^() {
    [weakSelf.channel invokeMethod:@"Firestore#snapshotsInSync"
                         arguments:@{
                           @"handle" : handle,
                         }];
  };

  id<FIRListenerRegistration> listenerRegistration =
      [firestore addSnapshotsInSyncListener:listener];
  @synchronized(_listeners) {
    _listeners[handle] = listenerRegistration;
  }
  result.success(nil);
}

- (void)waitForPendingWrites:(id)arguments
        withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  [firestore waitForPendingWritesWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)clearPersistence:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  [firestore clearPersistenceWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)terminate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  [firestore terminateWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      [FLTFirebaseFirestoreUtils destroyCachedFIRFirestoreInstanceForKey:firestore.app.name];
      result.success(nil);
    }
  }];
}

- (void)enableNetwork:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  [firestore enableNetworkWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)disableNetwork:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  [firestore disableNetworkWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)transactionCreate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  NSNumber *transactionId = arguments[@"transactionId"];
  NSNumber *transactionTimeout = arguments[@"timeout"];

  __weak __typeof__(self) weakSelf = self;
  NSDictionary *transactionAttemptArguments = @{
    @"transactionId" : transactionId,
    @"appName" : [FLTFirebasePlugin firebaseAppNameFromIosName:firestore.app.name]
  };

  id transactionRunBlock = ^id(FIRTransaction *transaction, NSError **pError) {
    @synchronized(self->_transactions) {
      self->_transactions[transactionId] = transaction;
    }

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSDictionary *attemptedTransactionResponse;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [weakSelf.channel invokeMethod:@"Transaction#attempt"
                           arguments:transactionAttemptArguments
                              result:^(id dartAttemptTransactionResult) {
                                attemptedTransactionResponse = dartAttemptTransactionResult;
                                dispatch_semaphore_signal(semaphore);
                              }];
    });

    long timedOut = dispatch_semaphore_wait(
        semaphore,
        dispatch_time(DISPATCH_TIME_NOW, [transactionTimeout integerValue] * NSEC_PER_MSEC));
    NSString *dartResponseType =
        attemptedTransactionResponse ? attemptedTransactionResponse[@"type"] : @"ERROR";

    if (timedOut) {
      *pError = [NSError errorWithDomain:FIRFirestoreErrorDomain
                                    code:FIRFirestoreErrorCodeDeadlineExceeded
                                userInfo:@{}];
      return nil;
    }

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
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
    @synchronized(self->_transactions) {
      [self->_transactions removeObjectForKey:transactionId];
    }
  };

  [firestore runTransactionWithBlock:transactionRunBlock completion:transactionCompleteBlock];
}

- (void)transactionGet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSNumber *transactionId = arguments[@"transactionId"];
    FIRDocumentReference *document = arguments[@"reference"];

    FIRTransaction *transaction = self->_transactions[transactionId];

    NSError *error = [[NSError alloc] init];
    FIRDocumentSnapshot *snapshot = [transaction getDocument:document error:&error];

    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else if (snapshot != nil) {
      result.success(snapshot);
    } else {
      result.success(nil);
    }
  });
}

- (void)documentSet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  id data = arguments[@"data"];
  FIRDocumentReference *document = arguments[@"reference"];

  NSDictionary *options = arguments[@"options"];
  void (^completionBlock)(NSError *) = ^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  };

  if ([options[@"merge"] isEqual:@YES]) {
    [document setData:data merge:YES completion:completionBlock];
  } else if (![options[@"mergeFields"] isEqual:[NSNull null]]) {
    [document setData:data mergeFields:options[@"mergeFields"] completion:completionBlock];
  } else {
    [document setData:data completion:completionBlock];
  }
}

- (void)documentUpdate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  id data = arguments[@"data"];
  FIRDocumentReference *document = arguments[@"reference"];

  [document updateData:data
            completion:^(NSError *error) {
              if (error != nil) {
                result.error(nil, nil, nil, error);
              } else {
                result.success(nil);
              }
            }];
}

- (void)documentDelete:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDocumentReference *document = arguments[@"reference"];

  [document deleteDocumentWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)documentGet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDocumentReference *document = arguments[@"reference"];
  FIRFirestoreSource source = [FLTFirebaseFirestoreUtils FIRFirestoreSourceFromArguments:arguments];
  id completion = ^(FIRDocumentSnapshot *_Nullable snapshot, NSError *_Nullable error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(snapshot);
    }
  };

  [document getDocumentWithSource:source completion:completion];
}

- (void)queryAddSnapshotListener:(id)arguments
            withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  __weak __typeof__(self) weakSelf = self;
  FIRQuery *query = arguments[@"query"];

  if (query == nil) {
    result.error(@"sdk-error",
                 @"An error occurred while parsing query arguments, see native logs for more "
                 @"information. Please report this issue.",
                 nil, nil);
    return;
  }

  NSNumber *handle = arguments[@"handle"];
  NSNumber *includeMetadataChanges = arguments[@"includeMetadataChanges"];

  id listener = ^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
    if (error != nil) {
      NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];
      [weakSelf.channel
          invokeMethod:@"QuerySnapshot#error"
             arguments:@{
               @"handle" : handle,
               @"error" : @{@"code" : codeAndMessage[0], @"message" : codeAndMessage[1]},
             }];
    } else if (snapshot != nil) {
      [weakSelf.channel invokeMethod:@"QuerySnapshot#event"
                           arguments:@{
                             @"handle" : handle,
                             @"snapshot" : snapshot,
                           }];
    }
  };

  id<FIRListenerRegistration> listenerRegistration =
      [query addSnapshotListenerWithIncludeMetadataChanges:includeMetadataChanges.boolValue
                                                  listener:listener];

  @synchronized(_listeners) {
    _listeners[handle] = listenerRegistration;
  }
  result.success(nil);
}

- (void)documentAddSnapshotListener:(id)arguments
               withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  __weak __typeof__(self) weakSelf = self;

  NSNumber *handle = arguments[@"handle"];
  NSNumber *includeMetadataChanges = arguments[@"includeMetadataChanges"];

  FIRDocumentReference *document = arguments[@"reference"];

  id listener = ^(FIRDocumentSnapshot *snapshot, NSError *_Nullable error) {
    if (error != nil) {
      NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];
      [weakSelf.channel
          invokeMethod:@"DocumentSnapshot#error"
             arguments:@{
               @"handle" : handle,
               @"error" : @{@"code" : codeAndMessage[0], @"message" : codeAndMessage[1]},
             }];
    } else if (snapshot != nil) {
      [weakSelf.channel invokeMethod:@"DocumentSnapshot#event"
                           arguments:@{
                             @"handle" : handle,
                             @"snapshot" : snapshot,
                           }];
    }
  };

  id<FIRListenerRegistration> listenerRegistration =
      [document addSnapshotListenerWithIncludeMetadataChanges:includeMetadataChanges.boolValue
                                                     listener:listener];

  @synchronized(_listeners) {
    _listeners[handle] = listenerRegistration;
  }
  result.success(nil);
}

- (void)queryGet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRQuery *query = arguments[@"query"];

  if (query == nil) {
    result.error(@"sdk-error",
                 @"An error occurred while parsing query arguments, see native logs for more "
                 @"information. Please report this issue.",
                 nil, nil);
    return;
  }

  FIRFirestoreSource source = [FLTFirebaseFirestoreUtils FIRFirestoreSourceFromArguments:arguments];
  [query getDocumentsWithSource:source
                     completion:^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
                       if (error != nil) {
                         result.error(nil, nil, nil, error);
                       } else {
                         result.success(snapshot);
                       }
                     }];
}

- (void)removeListener:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSNumber *handle = arguments[@"handle"];
  @synchronized(_listeners) {
    if (_listeners[handle] != nil) {
      [_listeners[handle] remove];
      [_listeners removeObjectForKey:handle];
    }
  }
  result.success(nil);
}

- (void)batchCommit:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  NSArray<NSDictionary *> *writes = arguments[@"writes"];
  FIRWriteBatch *batch = [firestore batch];

  for (NSDictionary *write in writes) {
    NSString *type = write[@"type"];
    NSString *path = write[@"path"];
    FIRDocumentReference *reference = [firestore documentWithPath:path];

    if ([@"DELETE" isEqualToString:type]) {
      [batch deleteDocument:reference];
    } else if ([@"UPDATE" isEqualToString:type]) {
      NSDictionary *data = write[@"data"];
      [batch updateData:data forDocument:reference];
    } else if ([@"SET" isEqualToString:type]) {
      NSDictionary *data = write[@"data"];
      NSDictionary *options = write[@"options"];
      if ([options[@"merge"] isEqual:@YES]) {
        [batch setData:data forDocument:reference merge:YES];
      } else if (![options[@"mergeFields"] isEqual:[NSNull null]]) {
        [batch setData:data forDocument:reference mergeFields:options[@"mergeFields"]];
      } else {
        [batch setData:data forDocument:reference];
      }
    }
  }

  [batch commitWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

@end
