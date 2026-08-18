/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#if TARGET_OS_OSX
#import <FirebaseFirestore/FirebaseFirestore.h>
#else
@import FirebaseFirestore;
#endif
#import <Foundation/Foundation.h>
#if __has_include(<cloud_firestore/FirestoreMessages.g.h>)
#import <cloud_firestore/FirestoreMessages.g.h>
#else
#import "../Public/FirestoreMessages.g.h"
#endif
@interface FirestorePigeonParser : NSObject

+ (FIRFilter *_Nonnull)filterFromJson:(NSDictionary<NSString *, id> *_Nullable)map;

+ (FIRQuery *_Nonnull)parseQueryWithParameters:(nonnull InternalQueryParameters *)parameters
                                     firestore:(nonnull FIRFirestore *)firestore
                                          path:(nonnull NSString *)path
                             isCollectionGroup:(Boolean)isCollectionGroup;

+ (FIRFirestoreSource)parseSource:(Source)source;

+ (NSArray<FIRFieldPath *> *_Nonnull)parseFieldPath:
    (NSArray<NSArray<NSString *> *> *_Nonnull)fieldPaths;

+ (FIRServerTimestampBehavior)parseServerTimestampBehavior:
    (ServerTimestampBehavior)serverTimestampBehavior;

+ (FIRListenSource)parseListenSource:(ListenSource)source;

+ (InternalSnapshotMetadata *_Nonnull)toPigeonSnapshotMetadata:
    (FIRSnapshotMetadata *_Nonnull)snapshotMetadata;

+ (InternalDocumentSnapshot *_Nonnull)
    toPigeonDocumentSnapshot:(FIRDocumentSnapshot *_Nonnull)documentSnapshot
     serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior;

+ (DocumentChangeType)toPigeonDocumentChangeType:(FIRDocumentChangeType)documentChangeType;

+ (InternalDocumentChange *_Nonnull)
     toPigeonDocumentChange:(FIRDocumentChange *_Nonnull)documentChange
    serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior;

+ (NSArray<InternalDocumentChange *> *_Nonnull)
    toPigeonDocumentChanges:(NSArray<FIRDocumentChange *> *_Nonnull)documentChanges
    serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior;

+ (InternalQuerySnapshot *_Nonnull)toPigeonQuerySnapshot:(FIRQuerySnapshot *_Nonnull)querySnaphot
                                 serverTimestampBehavior:
                                     (FIRServerTimestampBehavior)serverTimestampBehavior;

@end
