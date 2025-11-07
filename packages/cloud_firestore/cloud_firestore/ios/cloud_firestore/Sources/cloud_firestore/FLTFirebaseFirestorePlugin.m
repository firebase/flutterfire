// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebaseFirestore;
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import <TargetConditionals.h>
#import "FirebaseFirestoreInternal/FIRPersistentCacheIndexManager.h"
#import "include/cloud_firestore/Private/FLTDocumentSnapshotStreamHandler.h"
#import "include/cloud_firestore/Private/FLTFirebaseFirestoreReader.h"
#import "include/cloud_firestore/Private/FLTFirebaseFirestoreUtils.h"
#import "include/cloud_firestore/Private/FLTLoadBundleStreamHandler.h"
#import "include/cloud_firestore/Private/FLTQuerySnapshotStreamHandler.h"
#import "include/cloud_firestore/Private/FLTSnapshotsInSyncStreamHandler.h"
#import "include/cloud_firestore/Private/FLTTransactionStreamHandler.h"
#import "include/cloud_firestore/Private/FirestorePigeonParser.h"
#import "include/cloud_firestore/Public/FLTFirebaseFirestorePlugin.h"

NSString *const kFLTFirebaseFirestoreChannelName = @"plugins.flutter.io/firebase_firestore";
NSString *const kFLTFirebaseFirestoreQuerySnapshotEventChannelName =
    @"plugins.flutter.io/firebase_firestore/query";
NSString *const kFLTFirebaseFirestoreDocumentSnapshotEventChannelName =
    @"plugins.flutter.io/firebase_firestore/document";
NSString *const kFLTFirebaseFirestoreSnapshotsInSyncEventChannelName =
    @"plugins.flutter.io/firebase_firestore/snapshotsInSync";
NSString *const kFLTFirebaseFirestoreTransactionChannelName =
    @"plugins.flutter.io/firebase_firestore/transaction";
NSString *const kFLTFirebaseFirestoreLoadBundleChannelName =
    @"plugins.flutter.io/firebase_firestore/loadBundle";

@interface FLTFirestoreClientLanguage : NSObject
+ (void)setClientLanguage:(NSString *)language;
@end

@interface FLTFirebaseFirestorePlugin ()
@property(nonatomic, retain) NSMutableDictionary *transactions;

/// Registers a unique event channel based on a channel prefix.
///
/// Once registered, the plugin will take care of removing the stream handler and cleaning up,
/// if the engine is detached.
///
/// This function generates a random ID.
///
/// @param prefix Channel prefix onto which the unique ID will be appended on. The convention is
///     "namespace/component" whereas the last / is added internally.
/// @param handler The handler object for responding to channel events and submitting data.
/// @return The generated identifier.
/// @see #registerEventChannel(String, String, StreamHandler)
- (NSString *)registerEventChannelWithPrefix:(NSString *)prefix
                               streamHandler:(NSObject<FlutterStreamHandler> *)handler;

/// Registers a unique event channel based on a channel prefix.
///
/// Once registered, the plugin will take care of removing the stream handler and cleaning up,
/// if the engine is detached.
///
/// @param prefix Channel prefix onto which the unique ID will be appended on. The convention is
/// "namespace/component" whereas the last / is added internally.
/// @param identifier A identifier which will be appended to the prefix.
/// @param handler The handler object for responding to channel events and submitting data.
/// @return The passed identifier.
/// @see #registerEventChannel(String, String, StreamHandler)
- (NSString *)registerEventChannelWithPrefix:(NSString *)prefix
                                  identifier:(NSString *)identifier
                               streamHandler:(NSObject<FlutterStreamHandler> *)handler;
@end

static NSCache<NSNumber *, NSString *> *_serverTimestampMap;

@implementation FLTFirebaseFirestorePlugin {
  NSMutableDictionary<NSString *, FlutterEventChannel *> *_eventChannels;
  NSMutableDictionary<NSString *, NSObject<FlutterStreamHandler> *> *_streamHandlers;
  NSMutableDictionary<NSString *, FLTTransactionStreamHandler *> *_transactionHandlers;
  NSObject<FlutterBinaryMessenger> *_binaryMessenger;
}

FlutterStandardMethodCodec *_codec;

+ (NSCache<NSNumber *, NSString *> *)serverTimestampMap {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _serverTimestampMap = [NSCache<NSNumber *, NSString *> new];
  });
  return _serverTimestampMap;
}

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
    _transactions = [NSMutableDictionary<NSNumber *, FIRTransaction *> dictionary];
    _eventChannels = [NSMutableDictionary dictionary];
    _streamHandlers = [NSMutableDictionary dictionary];
    _transactionHandlers = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFirebaseFirestorePlugin *instance =
      [[FLTFirebaseFirestorePlugin alloc] init:[registrar messenger]];
#if TARGET_OS_IPHONE
  [FLTFirestoreClientLanguage
      setClientLanguage:[NSString stringWithFormat:@"gl-dart/%@", @LIBRARY_VERSION]];
#endif

#if TARGET_OS_OSX
// TODO(Salakar): Publish does not exist on MacOS version of FlutterPluginRegistrar.
#else
  [registrar publish:instance];
#endif
  FirebaseFirestoreHostApiSetup(registrar.messenger, instance);
}

- (void)cleanupEventListeners {
  for (FlutterEventChannel *channel in self->_eventChannels.allValues) {
    [channel setStreamHandler:nil];
  }
  [self->_eventChannels removeAllObjects];
  for (NSObject<FlutterStreamHandler> *handler in self->_streamHandlers.allValues) {
    [handler onCancelWithArguments:nil];
  }
  [self->_streamHandlers removeAllObjects];

  @synchronized(self->_transactions) {
    [self->_transactions removeAllObjects];
  }
}

- (void)cleanupFirestoreInstances:(void (^)(void))completion {
  if ([FLTFirebaseFirestoreUtils count] > 0) {
    [FLTFirebaseFirestoreUtils cleanupFirestoreInstances:completion];
  } else {
    if (completion != nil) completion();
  }
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self cleanupEventListeners];
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  [self cleanupEventListeners];
  [self cleanupFirestoreInstances:completion];
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  return @{};
}

- (NSString *_Nonnull)firebaseLibraryName {
  return @LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return @LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseFirestoreChannelName;
}

#pragma mark - Firestore API

- (NSString *)registerEventChannelWithPrefix:(NSString *)prefix
                               streamHandler:(NSObject<FlutterStreamHandler> *)handler {
  return [self registerEventChannelWithPrefix:prefix
                                   identifier:[[[NSUUID UUID] UUIDString] lowercaseString]
                                streamHandler:handler];
}

- (NSString *)registerEventChannelWithPrefix:(NSString *)prefix
                                  identifier:(NSString *)identifier
                               streamHandler:(NSObject<FlutterStreamHandler> *)handler {
  NSString *channelName = [NSString stringWithFormat:@"%@/%@", prefix, identifier];

  FlutterEventChannel *channel = [[FlutterEventChannel alloc] initWithName:channelName
                                                           binaryMessenger:_binaryMessenger
                                                                     codec:_codec];

  [channel setStreamHandler:handler];
  [_eventChannels setObject:channel forKey:identifier];
  [_streamHandlers setObject:handler forKey:identifier];

  return identifier;
}

- (FIRFirestore *_Nullable)getFIRFirestoreFromAppNameFromPigeon:
    (FirestorePigeonFirebaseApp *)pigeonApp {
  @synchronized(self) {
    NSString *appNameDart = pigeonApp.appName;
    NSString *databaseUrl = pigeonApp.databaseURL;

    FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appNameDart];

    if ([FLTFirebaseFirestoreUtils getFirestoreInstanceByName:app.name
                                                  databaseURL:databaseUrl] != nil) {
      return [FLTFirebaseFirestoreUtils getFirestoreInstanceByName:app.name
                                                       databaseURL:databaseUrl];
    }

    FIRFirestoreSettings *settings = [[FIRFirestoreSettings alloc] init];
    if (pigeonApp.settings.persistenceEnabled != nil) {
      bool persistEnabled = [pigeonApp.settings.persistenceEnabled boolValue];

      // We default to the maximum amount of cache allowed.
      NSNumber *size = @(kFIRFirestoreCacheSizeUnlimited);

      if (pigeonApp.settings.cacheSizeBytes) {
        NSNumber *cacheSizeBytes = pigeonApp.settings.cacheSizeBytes;
        if ([cacheSizeBytes intValue] != -1) {
          size = cacheSizeBytes;
        }
      }

      if (persistEnabled) {
        settings.cacheSettings = [[FIRPersistentCacheSettings alloc] initWithSizeBytes:size];
      } else {
        settings.cacheSettings = [[FIRMemoryCacheSettings alloc]
            initWithGarbageCollectorSettings:[[FIRMemoryLRUGCSettings alloc] init]];
      }
    }

    if (pigeonApp.settings.host != nil) {
      settings.host = pigeonApp.settings.host;
      // Only allow changing ssl if host is also specified.
      if (pigeonApp.settings.sslEnabled != nil) {
        settings.sslEnabled = [pigeonApp.settings.sslEnabled boolValue];
      }
    }

    settings.dispatchQueue = [FLTFirebaseFirestoreReader getFirestoreQueue];

    FIRFirestore *firestore = [FIRFirestore firestoreForApp:app database:databaseUrl];
    firestore.settings = settings;

    [FLTFirebaseFirestoreUtils setCachedFIRFirestoreInstance:firestore
                                                  forAppName:app.name
                                                 databaseURL:databaseUrl];
    return firestore;
  }
}

- (FlutterError *)convertToFlutterError:(NSError *)error {
  NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];
  NSString *_Nullable code = codeAndMessage[0];
  NSString *_Nullable message = codeAndMessage[1];
  NSDictionary *_Nullable details = @{
    @"code" : code,
    @"message" : message,
  };

  return [FlutterError errorWithCode:code message:message details:details];
}

- (void)clearPersistenceApp:(nonnull FirestorePigeonFirebaseApp *)app
                 completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  [firestore clearPersistenceWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
}

- (void)disableNetworkApp:(nonnull FirestorePigeonFirebaseApp *)app
               completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  [firestore disableNetworkWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
}

- (void)documentReferenceDeleteApp:(nonnull FirestorePigeonFirebaseApp *)app
                           request:(nonnull DocumentReferenceRequest *)request
                        completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRDocumentReference *document = [firestore documentWithPath:request.path];

  [document deleteDocumentWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
}

- (void)terminate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRFirestore *firestore = arguments[@"firestore"];
  [firestore terminateWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      FLTFirebaseFirestoreExtension *firestoreExtension =
          [FLTFirebaseFirestoreUtils getCachedInstanceForFirestore:firestore];
      [FLTFirebaseFirestoreUtils destroyCachedInstanceForFirestore:firestore.app.name
                                                       databaseURL:firestoreExtension.databaseURL];
      result.success(nil);
    }
  }];
}

- (void)documentReferenceGetApp:(nonnull FirestorePigeonFirebaseApp *)app
                        request:(nonnull DocumentReferenceRequest *)request
                     completion:(nonnull void (^)(PigeonDocumentSnapshot *_Nullable,
                                                  FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRDocumentReference *document = [firestore documentWithPath:request.path];
  FIRFirestoreSource source = [FirestorePigeonParser parseSource:request.source.value];
  FIRServerTimestampBehavior serverTimestampBehavior =
      [FirestorePigeonParser parseServerTimestampBehavior:request.serverTimestampBehavior.value];

  id completionGet = ^(FIRDocumentSnapshot *_Nullable snapshot, NSError *_Nullable error) {
    if (error != nil) {
      completion(nil, [self convertToFlutterError:error]);
    } else {
      completion([FirestorePigeonParser toPigeonDocumentSnapshot:snapshot
                                         serverTimestampBehavior:serverTimestampBehavior],
                 nil);
    }
  };

  [document getDocumentWithSource:source completion:completionGet];
}

- (void)documentReferenceSetApp:(nonnull FirestorePigeonFirebaseApp *)app
                        request:(nonnull DocumentReferenceRequest *)request
                     completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  id data = request.data;
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRDocumentReference *document = [firestore documentWithPath:request.path];

  void (^completionBlock)(NSError *) = ^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  };

  if ([request.option.merge isEqual:@YES]) {
    [document setData:data merge:YES completion:completionBlock];
  } else if (request.option.mergeFields) {
    [document setData:data
          mergeFields:[FirestorePigeonParser parseFieldPath:request.option.mergeFields]
           completion:completionBlock];
  } else {
    [document setData:data completion:completionBlock];
  }
}

- (void)documentReferenceSnapshotApp:(nonnull FirestorePigeonFirebaseApp *)app
                          parameters:(nonnull DocumentReferenceRequest *)parameters
              includeMetadataChanges:(nonnull NSNumber *)includeMetadataChanges
                              source:(ListenSource)source
                          completion:(nonnull void (^)(NSString *_Nullable,
                                                       FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRDocumentReference *document = [firestore documentWithPath:parameters.path];
  FIRServerTimestampBehavior serverTimestampBehavior =
      [FirestorePigeonParser parseServerTimestampBehavior:parameters.serverTimestampBehavior.value];
  FIRListenSource listenSource = [FirestorePigeonParser parseListenSource:source];

  completion(
      [self registerEventChannelWithPrefix:kFLTFirebaseFirestoreDocumentSnapshotEventChannelName
                             streamHandler:[[FLTDocumentSnapshotStreamHandler alloc]
                                                     initWithFirestore:firestore
                                                             reference:document
                                                includeMetadataChanges:includeMetadataChanges
                                                                           .boolValue
                                               serverTimestampBehavior:serverTimestampBehavior
                                                                source:listenSource]],
      nil);
}

- (void)documentReferenceUpdateApp:(nonnull FirestorePigeonFirebaseApp *)app
                           request:(nonnull DocumentReferenceRequest *)request
                        completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  id data = request.data;
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRDocumentReference *document = [firestore documentWithPath:request.path];

  [document updateData:data
            completion:^(NSError *error) {
              if (error != nil) {
                completion([self convertToFlutterError:error]);
              } else {
                completion(nil);
              }
            }];
}

- (void)enableNetworkApp:(nonnull FirestorePigeonFirebaseApp *)app
              completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  [firestore enableNetworkWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
}

- (void)loadBundleApp:(nonnull FirestorePigeonFirebaseApp *)app
               bundle:(nonnull FlutterStandardTypedData *)bundle
           completion:(nonnull void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];

  completion([self registerEventChannelWithPrefix:kFLTFirebaseFirestoreLoadBundleChannelName
                                    streamHandler:[[FLTLoadBundleStreamHandler alloc]
                                                      initWithFirestore:firestore
                                                                 bundle:bundle]],
             nil);
}

- (void)namedQueryGetApp:(nonnull FirestorePigeonFirebaseApp *)app
                    name:(nonnull NSString *)name
                 options:(nonnull PigeonGetOptions *)options
              completion:(nonnull void (^)(PigeonQuerySnapshot *_Nullable,
                                           FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];

  FIRFirestoreSource source = [FirestorePigeonParser parseSource:options.source];
  FIRServerTimestampBehavior serverTimestampBehavior =
      [FirestorePigeonParser parseServerTimestampBehavior:options.serverTimestampBehavior];

  [firestore
      getQueryNamed:name
         completion:^(FIRQuery *_Nullable query) {
           if (query == nil) {
             completion(nil,
                        [FlutterError errorWithCode:@"non-existent-named-query"
                                            message:@"Named query has not been found. Please check "
                                                    @"it has been loaded properly via loadBundle()."
                                            details:nil]);

             return;
           }
           [query getDocumentsWithSource:source
                              completion:^(FIRQuerySnapshot *_Nullable snapshot,
                                           NSError *_Nullable error) {
                                if (error != nil) {
                                  completion(nil, [self convertToFlutterError:error]);
                                } else {
                                  completion([FirestorePigeonParser
                                                   toPigeonQuerySnapshot:snapshot
                                                 serverTimestampBehavior:serverTimestampBehavior],
                                             nil);
                                }
                              }];
         }];
}

- (void)queryGetApp:(nonnull FirestorePigeonFirebaseApp *)app
                 path:(nonnull NSString *)path
    isCollectionGroup:(nonnull NSNumber *)isCollectionGroup
           parameters:(nonnull PigeonQueryParameters *)parameters
              options:(nonnull PigeonGetOptions *)options
           completion:(nonnull void (^)(PigeonQuerySnapshot *_Nullable,
                                        FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRQuery *query = [FirestorePigeonParser parseQueryWithParameters:parameters
                                                          firestore:firestore
                                                               path:path
                                                  isCollectionGroup:[isCollectionGroup boolValue]];
  if (query == nil) {
    completion(nil, [FlutterError errorWithCode:@"error-parsing"
                                        message:@"An error occurred while parsing query arguments, "
                                                @"this is most likely an error with this SDK."
                                        details:nil]);
    return;
  }

  FIRFirestoreSource source = [FirestorePigeonParser parseSource:options.source];
  FIRServerTimestampBehavior serverTimestampBehavior =
      [FirestorePigeonParser parseServerTimestampBehavior:options.serverTimestampBehavior];

  [query getDocumentsWithSource:source
                     completion:^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
                       if (error != nil) {
                         completion(nil, [self convertToFlutterError:error]);
                       } else {
                         completion(
                             [FirestorePigeonParser toPigeonQuerySnapshot:snapshot
                                                  serverTimestampBehavior:serverTimestampBehavior],
                             nil);
                       }
                     }];
}

- (void)querySnapshotApp:(nonnull FirestorePigeonFirebaseApp *)app
                      path:(nonnull NSString *)path
         isCollectionGroup:(nonnull NSNumber *)isCollectionGroup
                parameters:(nonnull PigeonQueryParameters *)parameters
                   options:(nonnull PigeonGetOptions *)options
    includeMetadataChanges:(nonnull NSNumber *)includeMetadataChanges
                    source:(ListenSource)source
                completion:
                    (nonnull void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRQuery *query = [FirestorePigeonParser parseQueryWithParameters:parameters
                                                          firestore:firestore
                                                               path:path
                                                  isCollectionGroup:[isCollectionGroup boolValue]];
  if (query == nil) {
    completion(nil, [FlutterError errorWithCode:@"error-parsing"
                                        message:@"An error occurred while parsing query arguments, "
                                                @"this is most likely an error with this SDK."
                                        details:nil]);
    return;
  }

  FIRServerTimestampBehavior serverTimestampBehavior =
      [FirestorePigeonParser parseServerTimestampBehavior:options.serverTimestampBehavior];
  FIRListenSource listenSource = [FirestorePigeonParser parseListenSource:source];

  completion(
      [self registerEventChannelWithPrefix:kFLTFirebaseFirestoreQuerySnapshotEventChannelName
                             streamHandler:[[FLTQuerySnapshotStreamHandler alloc]
                                                     initWithFirestore:firestore
                                                                 query:query
                                                includeMetadataChanges:includeMetadataChanges
                                                                           .boolValue
                                               serverTimestampBehavior:serverTimestampBehavior
                                                                source:listenSource]],
      nil);
}

- (void)setIndexConfigurationApp:(nonnull FirestorePigeonFirebaseApp *)app
              indexConfiguration:(nonnull NSString *)indexConfiguration
                      completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];

  [firestore setIndexConfigurationFromJSON:indexConfiguration
                                completion:^(NSError *_Nullable error) {
                                  if (error != nil) {
                                    completion([self convertToFlutterError:error]);
                                  } else {
                                    completion(nil);
                                  }
                                }];
}

- (void)persistenceCacheIndexManagerRequestApp:(FirestorePigeonFirebaseApp *)app
                                       request:(PersistenceCacheIndexManagerRequest)request
                                    completion:(void (^)(FlutterError *_Nullable))completion {
  FIRPersistentCacheIndexManager *persistentCacheIndexManager =
      [self getFIRFirestoreFromAppNameFromPigeon:app].persistentCacheIndexManager;

  if (persistentCacheIndexManager) {
    switch (request) {
      case PersistenceCacheIndexManagerRequestEnableIndexAutoCreation:
        [persistentCacheIndexManager enableIndexAutoCreation];
        break;
      case PersistenceCacheIndexManagerRequestDisableIndexAutoCreation:
        [persistentCacheIndexManager disableIndexAutoCreation];
        break;
      case PersistenceCacheIndexManagerRequestDeleteAllIndexes:
        [persistentCacheIndexManager deleteAllIndexes];
        break;
    }
  } else {
    // Put because `persistentCacheIndexManager` is a nullable property
    NSLog(@"FLTFirebaseFirestore: `PersistentCacheIndexManager` is not available.");
  }
  completion(nil);
}

- (void)setLoggingEnabledLoggingEnabled:(nonnull NSNumber *)loggingEnabled
                             completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  [FIRFirestore enableLogging:[loggingEnabled boolValue]];
  completion(nil);
}

- (void)terminateApp:(nonnull FirestorePigeonFirebaseApp *)app
          completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  [firestore terminateWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      FLTFirebaseFirestoreExtension *firestoreExtension =
          [FLTFirebaseFirestoreUtils getCachedInstanceForFirestore:firestore];
      [FLTFirebaseFirestoreUtils destroyCachedInstanceForFirestore:firestore.app.name
                                                       databaseURL:firestoreExtension.databaseURL];
      completion(nil);
    }
  }];
}

- (void)transactionGetApp:(nonnull FirestorePigeonFirebaseApp *)app
            transactionId:(nonnull NSString *)transactionId
                     path:(nonnull NSString *)path
               completion:(nonnull void (^)(PigeonDocumentSnapshot *_Nullable,
                                            FlutterError *_Nullable))completion {
  // Dispatching to main thread allow us to ensure that the auth token are fetched in time
  // for the transaction
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
    FIRDocumentReference *document = [firestore documentWithPath:path];

    FIRTransaction *transaction = self->_transactions[transactionId];

    if (transaction == nil) {
      completion(
          nil,
          [FlutterError
              errorWithCode:@"missing-transaction"
                    message:@"An error occurred while getting the native transaction. "
                            @"It could be caused by a timeout in a preceding transaction operation."
                    details:nil]);
      return;
    }

    NSError *error = nil;
    FIRDocumentSnapshot *snapshot = [transaction getDocument:document error:&error];

    if (error != nil) {
      completion(nil, [self convertToFlutterError:error]);
    } else if (snapshot != nil) {
      completion([FirestorePigeonParser toPigeonDocumentSnapshot:snapshot
                                         serverTimestampBehavior:FIRServerTimestampBehaviorNone],
                 nil);
    } else {
      completion(nil, nil);
    }
  });
}

- (void)transactionStoreResultTransactionId:(nonnull NSString *)transactionId
                                 resultType:(PigeonTransactionResult)resultType
                                   commands:(nullable NSArray<PigeonTransactionCommand *> *)commands
                                 completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  [_transactionHandlers[transactionId] receiveTransactionResponse:resultType commands:commands];

  completion(nil);
}

- (void)waitForPendingWritesApp:(nonnull FirestorePigeonFirebaseApp *)app
                     completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  [firestore waitForPendingWritesWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
}

- (void)writeBatchCommitApp:(nonnull FirestorePigeonFirebaseApp *)app
                     writes:(nonnull NSArray<PigeonTransactionCommand *> *)writes
                 completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];
  FIRWriteBatch *batch = [firestore batch];

  for (PigeonTransactionCommand *write in writes) {
    PigeonTransactionType type = write.type;
    NSString *path = write.path;
    FIRDocumentReference *reference = [firestore documentWithPath:path];

    switch (type) {
      case PigeonTransactionTypeGet:
        break;
      case PigeonTransactionTypeDeleteType:
        [batch deleteDocument:reference];
        break;
      case PigeonTransactionTypeUpdate:
        [batch updateData:write.data forDocument:reference];
        break;
      case PigeonTransactionTypeSet:
        if ([write.option.merge isEqual:@YES]) {
          [batch setData:write.data forDocument:reference merge:YES];
        } else if (write.option.mergeFields) {
          [batch setData:write.data
              forDocument:reference
              mergeFields:[FirestorePigeonParser parseFieldPath:write.option.mergeFields]];
        } else {
          [batch setData:write.data forDocument:reference];
        }
        break;
    }
  }

  [batch commitWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion([self convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
}

- (void)snapshotsInSyncSetupApp:(nonnull FirestorePigeonFirebaseApp *)app
                     completion:(nonnull void (^)(NSString *_Nullable,
                                                  FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];

  completion(
      [self registerEventChannelWithPrefix:kFLTFirebaseFirestoreSnapshotsInSyncEventChannelName
                             streamHandler:[[FLTSnapshotsInSyncStreamHandler alloc]
                                               initWithFirestore:firestore]],
      nil);
}

- (void)transactionCreateApp:(nonnull FirestorePigeonFirebaseApp *)app
                     timeout:(nonnull NSNumber *)timeout
                 maxAttempts:(nonnull NSNumber *)maxAttempts
                  completion:
                      (nonnull void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];

  NSString *transactionId = [[[NSUUID UUID] UUIDString] lowercaseString];

  FLTTransactionStreamHandler *handler =
      [[FLTTransactionStreamHandler alloc] initWithId:transactionId
          firestore:firestore
          timeout:timeout
          maxAttempts:maxAttempts
          started:^(FIRTransaction *_Nonnull transaction) {
            self->_transactions[transactionId] = transaction;
          }
          ended:^{
            self->_transactions[transactionId] = nil;
          }];

  _transactionHandlers[transactionId] = handler;

  completion([self registerEventChannelWithPrefix:kFLTFirebaseFirestoreTransactionChannelName
                                       identifier:transactionId
                                    streamHandler:handler],
             nil);
}

- (void)aggregateQueryApp:(nonnull FirestorePigeonFirebaseApp *)app
                     path:(nonnull NSString *)path
               parameters:(nonnull PigeonQueryParameters *)parameters
                   source:(AggregateSource)source
                  queries:(nonnull NSArray<AggregateQuery *> *)queries
        isCollectionGroup:(NSNumber *)isCollectionGroup
               completion:(nonnull void (^)(NSArray<AggregateQueryResponse *> *_Nullable,
                                            FlutterError *_Nullable))completion {
  FIRFirestore *firestore = [self getFIRFirestoreFromAppNameFromPigeon:app];

  FIRQuery *query = [FirestorePigeonParser parseQueryWithParameters:parameters
                                                          firestore:firestore
                                                               path:path
                                                  isCollectionGroup:[isCollectionGroup boolValue]];
  if (query == nil) {
    completion(nil, [FlutterError errorWithCode:@"error-parsing"
                                        message:@"An error occurred while parsing query arguments, "
                                                @"this is most likely an error with this SDK."
                                        details:nil]);
    return;
  }

  NSMutableArray<FIRAggregateField *> *aggregateFields =
      [[NSMutableArray<FIRAggregateField *> alloc] init];

  for (AggregateQuery *queryRequest in queries) {
    switch ([queryRequest type]) {
      case AggregateTypeCount:
        [aggregateFields addObject:[FIRAggregateField aggregateFieldForCount]];
        break;
      case AggregateTypeSum:
        [aggregateFields
            addObject:[FIRAggregateField aggregateFieldForSumOfField:[queryRequest field]]];
        break;
      case AggregateTypeAverage:
        [aggregateFields
            addObject:[FIRAggregateField aggregateFieldForAverageOfField:[queryRequest field]]];
        break;
      default:
        // Handle the default case
        break;
    }
  }

  FIRAggregateQuery *aggregateQuery = [query aggregate:aggregateFields];

  [aggregateQuery
      aggregationWithSource:FIRAggregateSourceServer
                 completion:^(FIRAggregateQuerySnapshot *_Nullable snapshot,
                              NSError *_Nullable error) {
                   if (error != nil) {
                     completion(nil, [self convertToFlutterError:error]);
                     return;
                   }
                   NSMutableArray<AggregateQueryResponse *> *aggregateResponses =
                       [[NSMutableArray alloc] init];

                   for (AggregateQuery *queryRequest in queries) {
                     switch (queryRequest.type) {
                       case AggregateTypeCount: {
                         double doubleValue = [snapshot.count doubleValue];

                         [aggregateResponses
                             addObject:[AggregateQueryResponse
                                           makeWithType:AggregateTypeCount
                                                  field:nil
                                                  value:[NSNumber numberWithDouble:doubleValue]]];
                         break;
                       }
                       case AggregateTypeSum: {
                         NSNumber *value = [snapshot
                             valueForAggregateField:[FIRAggregateField
                                                        aggregateFieldForSumOfField:[queryRequest
                                                                                        field]]];

                         [aggregateResponses
                             addObject:[AggregateQueryResponse
                                           makeWithType:AggregateTypeSum
                                                  field:queryRequest.field
                                                  // This passes either a double (wrapped in
                                                  // NSNumber) or null value
                                                  value:value != ((id)[NSNull null])
                                                            ? [NSNumber
                                                                  numberWithDouble:[value
                                                                                       doubleValue]]
                                                            : value]];
                         break;
                       }
                       case AggregateTypeAverage: {
                         NSNumber *value = [snapshot
                             valueForAggregateField:
                                 [FIRAggregateField
                                     aggregateFieldForAverageOfField:[queryRequest field]]];

                         [aggregateResponses
                             addObject:[AggregateQueryResponse
                                           makeWithType:AggregateTypeAverage
                                                  field:queryRequest.field
                                                  // This passes either a double (wrapped in
                                                  // NSNumber) or null value
                                                  value:value != ((id)[NSNull null])
                                                            ? [NSNumber
                                                                  numberWithDouble:[value
                                                                                       doubleValue]]
                                                            : value]];
                         break;
                       }
                     }
                   }

                   completion(aggregateResponses, nil);
                 }];
}

@end
