/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#import <Firebase/Firebase.h>
#import <Foundation/Foundation.h>
#import "FirestoreMessages.g.h"

@interface FirestorePigeonParser : NSObject

+ (FIRFilter *_Nonnull)filterFromJson:(NSDictionary<NSString *, id> *_Nullable)map;

+ (FIRQuery *_Nonnull)parseQueryWithParameters:(nonnull PigeonQueryParameters *)parameters
                                     firestore:(nonnull FIRFirestore *)firestore
                                          path:(nonnull NSString *)path
                             isCollectionGroup:(Boolean)isCollectionGroup;

+ (FIRFirestoreSource)parseSource:(Source)source;

+ (NSArray<FIRFieldPath *> *_Nonnull)parseFieldPath:
    (NSArray<NSArray<NSString *> *> *_Nonnull)fieldPaths;

+ (FIRServerTimestampBehavior)parseServerTimestampBehavior:
    (ServerTimestampBehavior)serverTimestampBehavior;

+ (FIRListenSource)parseListenSource:(ListenSource)source;

+ (PigeonSnapshotMetadata *_Nonnull)toPigeonSnapshotMetadata:
    (FIRSnapshotMetadata *_Nonnull)snapshotMetadata;

+ (PigeonDocumentSnapshot *_Nonnull)
    toPigeonDocumentSnapshot:(FIRDocumentSnapshot *_Nonnull)documentSnapshot
     serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior;

+ (DocumentChangeType)toPigeonDocumentChangeType:(FIRDocumentChangeType)documentChangeType;

+ (PigeonDocumentChange *_Nonnull)toPigeonDocumentChange:(FIRDocumentChange *_Nonnull)documentChange
                                 serverTimestampBehavior:
                                     (FIRServerTimestampBehavior)serverTimestampBehavior;

+ (NSArray<PigeonDocumentChange *> *_Nonnull)
    toPigeonDocumentChanges:(NSArray<FIRDocumentChange *> *_Nonnull)documentChanges
    serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior;

+ (PigeonQuerySnapshot *_Nonnull)toPigeonQuerySnapshot:(FIRQuerySnapshot *_Nonnull)querySnaphot
                               serverTimestampBehavior:
                                   (FIRServerTimestampBehavior)serverTimestampBehavior;

@end
