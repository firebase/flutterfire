// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#if TARGET_OS_OSX
#import <FirebaseFirestore/FirebaseFirestore.h>
#else
@import FirebaseFirestore;
#endif
#import <Foundation/Foundation.h>
#import "FLTFirebaseFirestoreExtension.h"

typedef NS_ENUM(UInt8, FirestoreDataType) {
  FirestoreDataTypeDateTime = 180,
  FirestoreDataTypeGeoPoint = 181,
  FirestoreDataTypeDocumentReference = 182,
  FirestoreDataTypeBlob = 183,
  FirestoreDataTypeArrayUnion = 184,
  FirestoreDataTypeArrayRemove = 185,
  FirestoreDataTypeDelete = 186,
  FirestoreDataTypeServerTimestamp = 187,
  FirestoreDataTypeTimestamp = 188,
  FirestoreDataTypeIncrementDouble = 189,
  FirestoreDataTypeIncrementInteger = 190,
  FirestoreDataTypeDocumentId = 191,
  FirestoreDataTypeFieldPath = 192,
  FirestoreDataTypeNaN = 193,
  FirestoreDataTypeInfinity = 194,
  FirestoreDataTypeNegativeInfinity = 195,
  FirestoreDataTypeFirestoreInstance = 196,
  FirestoreDataTypeFirestoreQuery = 197,
  FirestoreDataTypeFirestoreSettings = 198,
  FirestoreDataTypeVectorValue = 199,
};

@interface FLTFirebaseFirestoreReaderWriter : FlutterStandardReaderWriter
- (FlutterStandardWriter *_Nonnull)writerWithData:(NSMutableData *_Nullable)data;
- (FlutterStandardReader *_Nonnull)readerWithData:(NSData *_Nullable)data;
@end

@interface FLTFirebaseFirestoreUtils : NSObject
+ (FIRFirestoreSource)FIRFirestoreSourceFromArguments:(NSDictionary *_Nonnull)arguments;
+ (NSArray *_Nonnull)ErrorCodeAndMessageFromNSError:(NSError *_Nonnull)error;
+ (FLTFirebaseFirestoreExtension *_Nullable)
    getCachedFIRFirestoreInstanceForAppName:(NSString *_Nonnull)appName
                                databaseURL:(NSString *_Nonnull)url;
+ (void)setCachedFIRFirestoreInstance:(FIRFirestore *_Nonnull)firestore
                           forAppName:(NSString *_Nonnull)appName
                          databaseURL:(NSString *_Nonnull)url;
+ (void)destroyCachedInstanceForFirestore:(NSString *_Nonnull)appName
                              databaseURL:(NSString *_Nonnull)databaseURL;
+ (FIRFirestore *_Nullable)getFirestoreInstanceByName:(NSString *_Nonnull)appName
                                          databaseURL:(NSString *_Nonnull)databaseURL;
+ (void)cleanupFirestoreInstances:(void (^_Nullable)(void))completion;
+ (NSUInteger)count;
+ (FLTFirebaseFirestoreExtension *_Nullable)getCachedInstanceForFirestore:
    (FIRFirestore *_Nonnull)firestore;
@end
