/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

//
//  FLTLoadBundleStreamHandler.h
//  Pods
//
//  Created by Russell Wheatley on 05/05/2021.
//
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

NS_ASSUME_NONNULL_BEGIN

@interface FLTLoadBundleStreamHandler : NSObject <FlutterStreamHandler>
@property(nonatomic, strong) FIRFirestore *firestore;
@property(nonatomic, strong) FlutterStandardTypedData *bundle;

- (instancetype)initWithFirestore:(FIRFirestore *)firestore
                           bundle:(FlutterStandardTypedData *)bundle;

@end

NS_ASSUME_NONNULL_END
