// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTDocumentSnapshotStreamHandler.h"
#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Private/FLTQuerySnapshotStreamHandler.h"
#import "Private/FLTSnapshotsInSyncStreamHandler.h"
#import "Private/FLTTransactionStreamHandler.h"

#import "Public/FLTFirebaseFirestorePlugin.h"

NSString *const kFLTFirebaseFirestoreChannelName = @"plugins.flutter.io/firebase_firestore";
NSString *const kFLTFirebaseFirestoreQuerySnapshotEventChannelName =
    @"plugins.flutter.io/firebase_firestore/query";
NSString *const kFLTFirebaseFirestoreDocumentSnapshotEventChannelName =
    @"plugins.flutter.io/firebase_firestore/document";
NSString *const kFLTFirebaseFirestoreSnapshotsInSyncEventChannelName =
    @"plugins.flutter.io/firebase_firestore/snapshotsInSync";
NSString *const kFLTFirebaseFirestoreTransactionChannelName =
    @"plugins.flutter.io/firebase_firestore/transaction";

@interface FLTFirebaseFirestorePlugin ()
@property(nonatomic, retain) NSMutableDictionary *transactions;
@end

@implementation FLTFirebaseFirestorePlugin {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;

  NSMutableDictionary<NSString *, FlutterEventChannel *> *_transactionChannels;
  NSMutableDictionary<NSString *, FLTTransactionStreamHandler *> *_transactionHandlers;
  NSObject<FlutterBinaryMessenger> *_binaryMessenger;
}

FlutterStandardMethodCodec *_codec;

+ (void)initialize {
  _codec =
      [FlutterStandardMethodCodec codecWithReaderWriter:[FLTFirebaseFirestoreReaderWriter new]];
}

#pragma mark - FlutterPlugin

// Returns a singleton instance of the Firebase Firestore plugin.
//+ (instancetype)sharedInstance {
//  static dispatch_once_t onceToken;
//  static FLTFirebaseFirestorePlugin *instance;
//
//  dispatch_once(&onceToken, ^{
//    instance = [[FLTFirebaseFirestorePlugin alloc] init];
//    // Register with the Flutter Firebase plugin registry.
//    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
//  });
//
//  return instance;
//}

- (instancetype)init:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    _binaryMessenger = messenger;
    _listeners = [NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> dictionary];
    _transactions = [NSMutableDictionary<NSNumber *, FIRTransaction *> dictionary];
    _transactionChannels = [NSMutableDictionary dictionary];
    _transactionHandlers = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseFirestoreChannelName
                                  binaryMessenger:[registrar messenger]
                                            codec:_codec];

  FLTFirebaseFirestorePlugin *instance =
      [[FLTFirebaseFirestorePlugin alloc] init:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];

  FlutterEventChannel *querySnapshotChannel =
      [FlutterEventChannel eventChannelWithName:kFLTFirebaseFirestoreQuerySnapshotEventChannelName
                                binaryMessenger:registrar.messenger
                                          codec:_codec];

  [querySnapshotChannel setStreamHandler:[[FLTQuerySnapshotStreamHandler alloc] init]];

  FlutterEventChannel *documentSnapshotChannel = [FlutterEventChannel
      eventChannelWithName:kFLTFirebaseFirestoreDocumentSnapshotEventChannelName
           binaryMessenger:registrar.messenger
                     codec:_codec];

  [documentSnapshotChannel setStreamHandler:[[FLTDocumentSnapshotStreamHandler alloc] init]];

  FlutterEventChannel *snapshotsInSyncChannel =
      [FlutterEventChannel eventChannelWithName:kFLTFirebaseFirestoreSnapshotsInSyncEventChannelName
                                binaryMessenger:registrar.messenger
                                          codec:_codec];

  [snapshotsInSyncChannel setStreamHandler:[[FLTSnapshotsInSyncStreamHandler alloc] init]];

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

  if ([@"Transaction#get" isEqualToString:call.method]) {
    [self transactionGet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Transaction#create" isEqualToString:call.method]) {
    [self transactionCreate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Transaction#storeResult" isEqualToString:call.method]) {
    [self transactionStoreResult:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#set" isEqualToString:call.method]) {
    [self documentSet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#update" isEqualToString:call.method]) {
    [self documentUpdate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#delete" isEqualToString:call.method]) {
    [self documentDelete:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"DocumentReference#get" isEqualToString:call.method]) {
    [self documentGet:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Query#get" isEqualToString:call.method]) {
    [self queryGet:call.arguments withMethodCallResult:methodCallResult];
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

- (void)transactionGet:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *transactionId = arguments[@"transactionId"];
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

- (void)transactionCreate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *transactionId = [[[NSUUID UUID] UUIDString] lowercaseString];

  NSString *channelName = [[kFLTFirebaseFirestoreTransactionChannelName
      stringByAppendingString:@"/"] stringByAppendingString:transactionId];

  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:channelName
                                                           binaryMessenger:_binaryMessenger
                                                                     codec:_codec];

  FLTTransactionStreamHandler *handler =
      [[FLTTransactionStreamHandler alloc] initWithId:transactionId
                                 existingTransactions:_transactions];
  [channel setStreamHandler:handler];

  _transactionHandlers[transactionId] = handler;

  result.success(transactionId);
}

- (void)transactionStoreResult:(id)arguments
          withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *transactionId = arguments[@"transactionId"];
  NSDictionary *transactionResult = arguments[@"result"];

  [_transactionHandlers[transactionId] receiveTransactionResponse:transactionResult];

  result.success(nil);
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
